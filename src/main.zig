const std = @import("std");
const zi = @import("zi");

pub fn main(init: std.process.Init) !void {
    var env = std.process.Environ.Map.init(init.gpa);
    defer env.deinit();

    std.log.info("zig build", .{});
    var result = try zi.runStepCommand(init.gpa, init.io, .sh, "zig buid", &env);
    std.log.info(".{s}", .{result.stdout});
    init.gpa.free(result.stdout);
    init.gpa.free(result.stderr);

    std.log.info("zig build test", .{});
    result = try zi.runStepCommand(init.gpa, init.io, .sh, "zig buid test", &env);
    std.log.info(".{s}", .{result.stdout});
    init.gpa.free(result.stdout);
    init.gpa.free(result.stderr);
}
