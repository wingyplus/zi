// Q: how to run the command
// A: we need a shell to run command as a tty

const std = @import("std");

const Result = struct {
    // Know about the result of the command, exit code, signal, etc.
    term: std.process.Child.Term,
};

// A shell to run the command.
const Shell = enum {
    bash,
    zsh,
    fish,
};

/// Run a command in the step.
///
/// Returns a result from the command.
pub fn runStepCommand(allocator: std.mem.Allocator, io: std.Io, shell: Shell, command: []const u8, env: *std.process.Environ.Map) !std.process.RunResult {
    // TODO: env support.
    // TODO: run with shell.
    _ = shell; // autofix

    // We don't support stdin in any case.
    return try std.process.run(
        allocator,
        io,
        .{
            .argv = &[_][]const u8{ "bash", "-c", command },
            .environ_map = env,
        },
    );
}

test runStepCommand {
    const io = std.testing.io;
    const allocator = std.testing.allocator;

    var env = std.process.Environ.Map.init(allocator);
    defer env.deinit();

    const result = try runStepCommand(allocator, io, .bash, "echo 'hello, world'", &env);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try std.testing.expectEqual(0, result.term.exited);
    try std.testing.expectEqualStrings("hello, world\n", result.stdout);
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
