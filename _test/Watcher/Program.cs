// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

 using var watcher = new FileSystemWatcher(@"/home/ben/c64/bin/");

// generating the file in vice monitor with 
// s "mem.txt" 0 3887 38c0


watcher.Filter = "mem.txt";
watcher.Created += (o, e) => {
    var source = e.FullPath;
    var dest = $"/home/ben/c64/bin/mem.{System.DateTime.Now.Minute}{System.DateTime.Now.Second}.txt";

    Console.WriteLine(source + " => " + dest);

    System.IO.File.Move(source, dest);
};

watcher.EnableRaisingEvents = true;

Console.ReadLine();

