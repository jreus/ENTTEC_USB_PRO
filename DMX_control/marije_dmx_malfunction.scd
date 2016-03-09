// For some reason this freezes ... the routine keeps running but I lose all control over SC lang..
// could be driver issues on my older macbook pro?


a = ();
~device = SerialPort.devices[3];
a.dmx = DMX.new;
a.dmx.device = EntTecDMXUSBPro.new( ~device );
b = DMXCue.new;	// dmx blackout
a.dmx.currentCue = b;
a.dmx.setCue;


b = DMXCue.new;	// dmx blackout
b.put(0,1);
a.dmx.currentCue = b;
a.dmx.setCue;



~del = 0.1;
Tdef(\dmx, {
	var arr = [1,0,0,0,0,0];
	var i = 0;
	var newCue;
	inf.do {
		newCue = DMXCue.new;
		arr = arr.rotate(1);
		arr.do({|val,it|
			newCue.put(it,val);
		});
		a.dmx.currentCue = newCue;
		a.dmx.setCue;
		arr.postln;
		~del.wait;
	};
});
Tdef(\dmx).play;
Tdef(\dmx).clear;





// Close it later..
a.dmx.device.close;






(
a = ();
a.dmxactive = 1;
a.routines = ();
a.dmx = ();
	a.dmx.lastCue = [0,0,0,0,0,0,0,0]; // 8 channel - maybe?
	a.dmx.currCue = [0,0,0,0,0,0,0,0];
	a.dmx.setVal_({|e,chan, value| a.dmx.currCue.put(chan, value); });
	a.dmx.getVal_({|e,chan| a.dmx.currCue.at(chan); });
	a.dmx.addVal_({|e,chan, value|
		var currVal = a.dmx.currCue.at(chan), newVal;
		newVal = currVal + value;
		if (newVal > 1.0) { newVal = 1.0 };
		a.dmx.currCue.put(chan, newVal);
		});
	a.dmx.subVal_({|e,chan, value|
		var currVal = a.dmx.currCue.at(chan), newVal;
		newVal = currVal - value;
		if (newVal < 0.0) { newVal = 0.0 };
		a.dmx.currCue.put(chan, newVal);
		});

	a.dmx.transferRate = 0.1; // 0.042 is slightly slower than 24 fps
~device = SerialPort.devices[3];
	if (a.dmxactive == 1)
	{
	a.dmx.dev = DMX.new;
	a.dmx.dev.device = EntTecDMXUSBPro.new( ~device );
	b = DMXCue.new;	// dmx blackout
	a.dmx.dev.currentCue = b;
	a.dmx.dev.setCue;

	a.routines.dmx = Routine {
		var change = false, newCue = DMXCue.new;
		loop {
			change = false;
			newCue = DMXCue.new;
			a.dmx.currCue.do({|item, i|
				if (item != a.dmx.lastCue.at(i)) {
					change = true;
					a.dmx.lastCue.put(i, item);
				};
				newCue.put(i, item);
			});

			if (change) {
				a.dmx.dev.currentCue = newCue;
				a.dmx.dev.setCue;
			};

			(a.dmx.transferRate).wait;
		};
	};
	a.routines.dmx.play;
};
);
