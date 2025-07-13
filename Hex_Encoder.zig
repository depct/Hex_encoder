const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.print("Por gentileza, insira o nome do arquivo (ex: texto.txt) ou digite o texto a ser codificado:\n> ", .{});

    var input_buffer: [256]u8 = undefined;
    const input_slice = try stdin.readUntilDelimiterOrEof(&input_buffer, '\n') orelse &[_]u8{};
    const user_input = std.mem.trimRight(u8, input_slice, "\r\n");

    var data: []const u8 = undefined;

   
    if (std.fs.cwd().openFile(user_input, .{ .mode = .read_only })) |file| {
        defer file.close();
        const file_size = (try file.stat()).size;
        const file_data = try allocator.alloc(u8, file_size);
        defer allocator.free(file_data);
        _ = try file.readAll(file_data);
        data = file_data;
    } else |_| {
        
        data = user_input;
    }

    try stdout.print("Deseja nomear o arquivo de saída? (pressione ENTER para usar 'Thanks_Pedct.txt'):\n> ", .{});

    var name_buffer: [256]u8 = undefined;
    const name_slice = try stdin.readUntilDelimiterOrEof(&name_buffer, '\n') orelse &[_]u8{};
    const output_name = if (name_slice.len > 0) 
        std.mem.trim(u8, name_slice, " \r\n") 
    else 
        "Thanks_Pedct.txt";

    const output_file = try std.fs.cwd().createFile(output_name, .{});
    defer output_file.close();

    
    const writer = output_file.writer();
    for (data) |b| {
        try writer.print("{x:0>2}", .{b});  
    }

    try writer.print("\n\nPowered by Pedct\n", .{});
    try stdout.print("Arquivo '{s}' criado com sucesso! ✅\n", .{output_name});

    
    try stdout.print("Pressione Enter para sair...", .{});
    _ = try stdin.readByte();
}