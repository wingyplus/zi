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

// TODO: env support.
// TODO: run with shell.
pub fn runStep(allocator: std.mem.Allocator, io: std.Io, shell: Shell, command: []const u8) !std.process.RunResult {
    _ = shell; // autofix

    // We don't support stdin in any case.
    return try std.process.run(
        allocator,
        io,
        .{
            .argv = &[_][]const u8{ "bash", "-c", command },
        },
    );
}

test runStep {
    const io = std.testing.io;
    const allocator = std.testing.allocator;

    const result = try runStep(allocator, io, .bash, "echo 'hello, world'");
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try std.testing.expectEqual(0, result.term.exited);
    try std.testing.expectEqualStrings("hello, world\n", result.stdout);
}
