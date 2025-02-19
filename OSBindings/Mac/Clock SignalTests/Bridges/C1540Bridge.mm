//
//  C1540Bridge.m
//  Clock Signal
//
//  Created by Thomas Harte on 09/07/2016.
//  Copyright 2016 Thomas Harte. All rights reserved.
//

#import "C1540Bridge.h"
#include "C1540.hpp"
#include "NSData+StdVector.h"
#include "CSROMFetcher.hpp"

#include <memory>

class VanillaSerialPort: public Commodore::Serial::Port {
	public:
		void set_input(Commodore::Serial::Line line, Commodore::Serial::LineLevel value) {
			_input_line_levels[(int)line] = value;
		}

		Commodore::Serial::LineLevel _input_line_levels[5];
};

@implementation C1540Bridge {
	std::unique_ptr<Commodore::C1540::Machine> _c1540;
	Commodore::Serial::Bus _serialBus;
	VanillaSerialPort _serialPort;
}

- (instancetype)init {
	self = [super init];
	if(self) {
		auto rom_fetcher = CSROMFetcher();
		auto roms = rom_fetcher(Commodore::C1540::Machine::rom_request(Commodore::C1540::Personality::C1540));
		_c1540 = std::make_unique<Commodore::C1540::Machine>(Commodore::C1540::Personality::C1540, roms);
		_c1540->set_serial_bus(_serialBus);
		Commodore::Serial::attach(_serialPort, _serialBus);
	}
	return self;
}

- (void)runForCycles:(NSUInteger)numberOfCycles {
	_c1540->run_for(Cycles((int)numberOfCycles));
}

- (void)setAttentionLine:(BOOL)attentionLine {
	_serialPort.set_output(Commodore::Serial::Line::Attention, attentionLine ? Commodore::Serial::LineLevel::High : Commodore::Serial::LineLevel::Low);
}

- (BOOL)attentionLine {
	return _serialPort._input_line_levels[size_t(Commodore::Serial::Line::Attention)];
}

- (void)setDataLine:(BOOL)dataLine {
	_serialPort.set_output(Commodore::Serial::Line::Data, dataLine ? Commodore::Serial::LineLevel::High : Commodore::Serial::LineLevel::Low);
}

- (BOOL)dataLine {
	return _serialPort._input_line_levels[size_t(Commodore::Serial::Line::Data)];
}

- (void)setClockLine:(BOOL)clockLine {
	_serialPort.set_output(Commodore::Serial::Line::Clock, clockLine ? Commodore::Serial::LineLevel::High : Commodore::Serial::LineLevel::Low);
}

- (BOOL)clockLine {
	return _serialPort._input_line_levels[size_t(Commodore::Serial::Line::Clock)];
}

@end
