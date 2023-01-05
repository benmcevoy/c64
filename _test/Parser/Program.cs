// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

var offset = 2;
var files = System.IO.Directory.GetFiles("/home/ben/c64/_test/Parser/source/", "*.txt");

System.Array.Sort(files);


var osc1 = new System.Text.StringBuilder();
var osc2 = new System.Text.StringBuilder();
var osc3 = new System.Text.StringBuilder();
var accent1 = new System.Text.StringBuilder();
var accent2 = new System.Text.StringBuilder();
var accent3 = new System.Text.StringBuilder();
var chord = new System.Text.StringBuilder();
var tempo = new System.Text.StringBuilder();
var filter = new System.Text.StringBuilder();


foreach(var path in files) {

    var bytes = System.IO.File.ReadAllBytes(path);

    //Console.WriteLine($"osc1_pattern:       .byte {bytes[0+offset]}, {bytes[9+offset]}, 0, 0, 1");
    osc1.Append($"{bytes[0+offset]}, {bytes[9+offset]}, 0, 0, 8, ");
    osc2.Append($"{bytes[1+offset]}, {bytes[10+offset]}, 0, 0, 8, ");
    osc3.Append($"{bytes[2+offset]}, {bytes[11+offset]}, 0, 0, 8, ");

    accent1.Append($"{bytes[3+offset]}, {bytes[12+offset]}, 0, 0, 8, ");
    accent2.Append($"{bytes[4+offset]}, {bytes[13+offset]}, 0, 0, 8, ");
    accent3.Append($"{bytes[5+offset]}, {bytes[14+offset]}, 0, 0, 8, ");

    chord.Append($"{bytes[6+offset]}, {bytes[15+offset]}, 0, 0, 8, ");
    tempo.Append($"$10, 0, 0, 0, 8, ");
    filter.Append($"{bytes[8+offset]}, {bytes[17+offset]}, 0, 0, 8, ");

/*
 v0, v1, v2,  octave0, octave1, octave2, chord, tempo, filter
_voiceNumberOfBeats: .byte 1,0,0,0,0,0,1,0,0
// offset 0-8
_voiceRotation: .byte 3,4,5,0,0,0,0,0,0

// number of beats, rotation, transpose, instrument, ttl
// osc1_pattern:       .byte 6,5,0,0,8, 3,2,0,0,8, $FF

*/




}

Console.WriteLine("osc1_pattern:       .byte " + osc1.ToString() + "$ff");
Console.WriteLine("osc2_pattern:       .byte " + osc2.ToString() + "$ff");
Console.WriteLine("osc3_pattern:       .byte " + osc3.ToString() + "$ff");
Console.WriteLine("accent1_pattern:       .byte " + accent1.ToString() + "$ff");
Console.WriteLine("accent2_pattern:       .byte " + accent2.ToString() + "$ff");
Console.WriteLine("accent3_pattern:       .byte " + accent3.ToString() + "$ff");
Console.WriteLine("chord_pattern:       .byte " + chord.ToString() + "$ff");
Console.WriteLine("tempo_pattern:       .byte " + tempo.ToString() + "$ff");
Console.WriteLine("filter_pattern:       .byte " + filter.ToString() + "$ff");