const std = @import("std");

// A shell to run the command.
const Shell = enum {
    sh,
    bash,
    fish,
    zsh,
};

/// Run a command in the step.
///
/// Returns a result from the command.
pub fn runStepCommand(allocator: std.mem.Allocator, io: std.Io, shell: Shell, command: []const u8, env: *std.process.Environ.Map) !std.process.RunResult {
    const argv = switch (shell) {
        .sh => &[_][]const u8{ "sh", "-c", command },
        .bash => &[_][]const u8{ "bash", "-c", command },
        .fish => &[_][]const u8{ "fish", "-c", command },
        .zsh => &[_][]const u8{ "zsh", "-c", command },
    };

    // TODO: the result might need to translate into `
    //
    // - passed: RunResult
    // - failed: RunResult
    return try std.process.run(
        allocator,
        io,
        .{
            .argv = argv,
            .environ_map = env,
        },
    );
}

test runStepCommand {
    const io = std.testing.io;
    const allocator = std.testing.allocator;

    var env = std.process.Environ.Map.init(allocator);
    defer env.deinit();

    const shells = [_]Shell{ .sh, .bash, .fish };
    for (shells) |shell| {
        const result = try runStepCommand(allocator, io, shell, "echo 'hello, world'", &env);
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        try std.testing.expectEqual(0, result.term.exited);
        try std.testing.expectEqualStrings("hello, world\n", result.stdout);
    }
}

test "runStepCommand - injecting the environment variables" {
    const io = std.testing.io;
    const allocator = std.testing.allocator;

    var env = std.process.Environ.Map.init(allocator);
    defer env.deinit();

    try env.put("VAR", "VALUE");

    const result = try runStepCommand(allocator, io, .bash, "echo $VAR", &env);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try std.testing.expectEqual(0, result.term.exited);
    try std.testing.expectEqualStrings("VALUE\n", result.stdout);
}

test "runStepCommand - run code on different shell" {
    const io = std.testing.io;
    const allocator = std.testing.allocator;

    var env = std.process.Environ.Map.init(allocator);
    defer env.deinit();

    try env.put("VAR", "VALUE");

    const result = try runStepCommand(allocator, io, .fish, "echo $VAR", &env);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try std.testing.expectEqual(0, result.term.exited);
    try std.testing.expectEqualStrings("VALUE\n", result.stdout);
}
