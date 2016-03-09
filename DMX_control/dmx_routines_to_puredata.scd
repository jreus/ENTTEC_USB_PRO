n = NetAddr.new("127.0.0.1",8888); // PD DMX control

n.sendMsg("/dmx", 1.0, 1.0, 0.0, 0.0);

a = ();
a.maxch = 27; // maximum channels available in this DMX implementation

// Control a single DMX channel
a.sendDMX_({|e, chan, value|
	n.sendMsg("/dmxch",chan, value);
});

// Control a range of channels (good for simultaneously setting RGB on a single light)
a.sendDMXRange_({|e, startch, values|
	var prea, posta, send;
	if ((startch + values.size - 1) < a.maxch) {
		prea = startch;
		posta = a.maxch - values.size;
		send = Array.fill(prea,{1.5}) ++ values ++ Array.fill(posta,{1.5});
	n.sendMsg("/dmx", send[0],send[1],send[2],send[3],send[4],send[5],send[6],send[7],
	send[8],send[9],send[10],send[11],send[12],send[13],send[14],send[15],
	send[16],send[17],send[18],send[19],send[20],send[21],send[22],send[23]);

	} {
		"DMX values out of bounds".postln;
	};

});

/* Example
a.sendDMXRange(0,[0.0,0.0,0.0,0.0])
a.sendDMX(0, 0.0);
*/





// Flash one light
Tdef(\dmx0, {
	var j =0;
	var li = 0;
	var mt = 0.04;
	var max = 22;
	loop {
		a.sendDMXRange(li, [1.0,1.0,1.0]);
		mt.wait;
		a.sendDMXRange(li, [0.0,0,0]);
		mt.wait;

	};
});

Tdef(\dmx0).play;
Tdef(\dmx0).stop;

Tdef(\dmx1, {
	var j =0;
	var li1 = 0;
	var li2 = 3;
	var mt = 0.03;
	var max = 22;
	loop {
		a.sendDMXRange(li1, [1.0,0.4,0.4]);
		a.sendDMXRange(li2, [0.0,0.4,1.0]);
		mt.wait;
		a.sendDMXRange(li1, [0.0,0,0]);
		a.sendDMXRange(li2, [0.0,0,0]);
		mt.wait;
		4.wait;

	};
});

Tdef(\dmx1).play;
Tdef(\dmx1).stop;



// Chasers
Tdef(\dmx0, {
	var j =0;
	var max = 22;
	loop {
		max.do({|i|
			i.postln;
			a.sendDMX(i-1, 0.0);
			a.sendDMX(i, 1.0);
			0.44.wait;
		});
	}
});


// Multifade
Tdef(\dmx0, {
	var j =0;
	var max = 22;
	loop {
		max.do({|i|
			i.postln;
			a.sendDMX(i-1, 0.2);
			a.sendDMX(i+2, 0.8);
			a.sendDMX(i+5, 0.0);
			a.sendDMX(i+1, 0.0);
			a.sendDMX(i+6, 0.7);
			a.sendDMX(i+8, 1.0);
			0.14.wait;
		});
	}
});

(
// Flashing all
Tdef(\dmx0, {
	var j =0, tmp;
	var arron, arroff;
	arron = Array.fill(26, {|i|
		var pos = i % 3;
		switch(pos,
			0, {tmp = 1.0},
			1, {tmp = 0.67},
			2, {tmp = 0.1250}
		);
		tmp;
	});
	arroff = Array.fill(26, {|i|
		var pos = i % 3;
		switch(pos,
			0, {tmp = 246.56 / 255.0},
			1, {tmp = 224.83 / 255.0},
			2, {tmp = 255.00 / 255.0}
		);
		tmp;
	});

	arron = Array.fill(26, {1});
	arroff = Array.fill(26,{0});


	loop {
		2.do( {|i|
			if (i == 0) {
			a.sendDMXRange(0, arron);
			} {
				a.sendDMXRange(0, arroff);
			};
			0.04.wait;
		});
	};
});

)

Tdef(\dmx0).play;
Tdef(\dmx0).stop;

// Mappings RGB leds controls to channels
// for each light NUM, [Rchan,Gchan,Bchan]
a.dmxch = ();
a.dmxch = Array.fill(8, {|i| Array.series(3, i*3, 1)});

Array.fill(3, {0}) ++ [1,2,3,4,5,6] ++ Array.fill(5,{0})

/*
[
	0, [0,1,2],
	1, [3,4,5],
	2, [3,4,5],
	3, [3,4,5],
	4, [3,4,5],
	5, [3,4,5],
	6, [3,4,5],
	7, [3,4,5]
];
*/
// For now we use 8 lights 8x3 = 24 channels


// Sound
Ndef(\snd0, {
	var sig = SinOsc.ar(\fr0.kr(90), mul: 0.5) + SinOsc.ar(\fr1.kr(90), mul: 0.5);
	Pan2.ar(sig * \gain.kr(0.3));
});
Ndef(\snd0).play;

Ndef(\snd1, {
	var sig = SinOsc.ar(\fr0.kr(300), mul: 0.5) + SinOsc.ar(\fr1.kr(300), mul: 0.5);
	Pan2.ar(sig * \gain.kr(0.1));
});
Ndef(\snd1).play;




// Light behaviors controlled by synthdefs..

// Sinusoidal
Ndef(\ctrl0, {
	var s0,s1,s2;
	s0 = (SinOsc.ar(\fr0.kr(5), phase: \ph0.kr(0)) + 1) * 0.5 * \sc0.kr(1.0);
	s1 = (SinOsc.ar(\fr1.kr(5), phase: \ph1.kr(pi / 4)) + 1) * 0.5 * \sc0.kr(1.0);
	s2 = (SinOsc.ar(\fr2.kr(5), phase: \ph2.kr(pi / 2)) + 1) * 0.5 * \sc0.kr(1.0);
	SendReply.kr(Pulse.kr(\poll.kr(5)),'/osc0',[s0,s1,s2]);
});

// Pulse
Ndef(\ctrl0, {
	var s0,s1,s2;
	s0 = (Pulse.ar(\fr0.kr(5), width: \w0.kr(0.5)) + 1) * 0.5 * \sc0.kr(1.0);
	s0 = (Pulse.ar(\fr1.kr(5), width: \w1.kr(0.5)) + 1) * 0.5 * \sc0.kr(1.0);
	s0 = (Pulse.ar(\fr2.kr(5), width: \w2.kr(0.5)) + 1) * 0.5 * \sc0.kr(1.0);
	SendReply.kr(Pulse.kr(\poll.kr(5)),'/osc0',[s0,s1,s2]);
});





Ndef(\ctrl0).play;

Ndef(\ctrl0).set(\fr0, 2.5, \fr1, 1.6, \fr2, 7.2);
Ndef(\ctrl0).set(\ph0, 0, \ph1, 0, \ph2, 0);
Ndef(\ctrl0).set(\sc0, 0.5);
Ndef(\ctrl0).set(\poll, 30);

// Map control functions to DMX
OSCdef(\dmx0, {|msg|
	var val = msg[3];
	msg.postln;
	a.sendDMXRange(0,[msg[3],msg[4],val,msg[5]]); // independent phases
	//a.sendDMXRange(0,[msg[3],msg[3],val,msg[3]]); // unison
},'/osc0');

/* Stop all (good to include this as a class for livecoding? To be able to selectively stop routines - OSCdefs, and the like)
Ndef.clear;
OSCdef.freeAll;
*/


// Run pydon
"pydongui".runInTerminal;

/* Test minibee data
OSCdef(\minibee_monitor, {|msg| msg.postln;}, '/minibee/data');
OSCdef.freeAll;
*/

// View signals
a.data = ();
a.data[1] = SignalCharacteristics.new(1000);
a.data[1].makeGui;
a.data[2] = SignalCharacteristics.new(1000);
a.data[2].makeGui;

(
OSCdef( \minibee_monitor, { |msg|
	if (msg[1] == 1) {// minibee 1
		a.data[1].addValue( msg[2] ); // first data point - our analog sensor data: range will be between 0 and 1
	} {
		a.data[2].addValue(msg[2]);
	}
}, '/minibee/data' );
);


a.ctrl0spec = [0.8, 18.2, \exponential, 0.001].asSpec;
a.snd0spec = [86.0, 100.0, \lin, 0.001].asSpec;
a.snd1spec = [196.0, 210.0, \lin, 0.001].asSpec;

// Parse incoming minibee data
(
OSCdef(\minibee,{|msg|
	var bee;
	var c1 = a.ctrl0spec.map(msg[2]);
	bee = msg[1];
	switch(bee,
		1,{
			//("1: " + msg[2]).postln;
			Ndef(\ctrl0).set(\fr0, c1, \fr1, c1, \fr2, c1);
			Ndef(\snd0).set(\fr0, a.snd0spec.map(msg[2]));
			Ndef(\snd1).set(\fr0, a.snd1spec.map(msg[2]));

		},
		2,{
		},
		3,{
		},
		4,{
		},
		5,{
		}
	);

}, '/minibee/data');
);

// Specs vs. mapping.. I'd rather make a Mapper class to do flexible mapping for me.
// Test the specs.. maybe a good thing is to learn to use them!
~flickerSpec = [0.8, 18.2, \exponential, 0.001, 0.15].asSpec;
~flickerSpec.map(Array.series(100,0,1.0 / 100)).plot;
Ndef(\ctrl0).set(\fr0, 19.8);




// TODO - Contribute to a simple serial ENTEC implementation later. As a class. Upload it to SC repo.
