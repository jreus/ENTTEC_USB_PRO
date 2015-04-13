n = NetAddr.new("127.0.0.1",8888); // PD

n.sendMsg("/dmx", 1.0, 1.0, 0, 0, 1.0, 0);

// 0.042 is slightly slower than 24 fps
~del = 0.005;
~arr = [1.0,0.2,0.0,0.0,0.0,0.0];
// rotate
Tdef(\dmx, {
	var i = 0;
	var newCue;
	inf.do {
		~arr = ~arr.rotate(1);
		n.sendMsg("/dmx", ~arr[0],~arr[1],~arr[2],~arr[3],~arr[4],~arr[5],);
		~del.wait;
	};
});

// rotate
Tdef(\dmx, {
	var i = 0;
	var newCue;
	inf.do {|i|
		n.sendMsg("/dmx", (i%5 == 0), (i%2 == 0), (i%7 == 0), (i%10 == 0),(i%17 == 0),(i%21 == 0));
		~del.wait;
	};
});

Tdef(\dmx).play;
Tdef(\dmx).stop;

n.sendMsg("/dmx", 1,1,1,1,1,1);
n.sendMsg("/dmx", 0,0,0,0,0,0);


// TODO - NTS: Contribute to a simple serial ENTEC implementation later. As a class. Upload it to SC repo.
