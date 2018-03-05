extern crate verilated;

use std::ffi::CString;
use std::env;
use std::os::unix::ffi::OsStringExt;

pub trait Module {
    type Uut;

    fn tick(&mut self, tick_count: usize) -> bool;
    fn eval(&mut self);

    fn clock_up(&mut self);
    fn clock_down(&mut self);

    fn reset_up(&mut self);
    fn reset_down(&mut self);
}

pub struct TestBench<U>
where
    U: Module + Default,
{
    core: U,
    tick_count: usize,
}

impl<U> TestBench<U>
where
    U: Module + Default,
{
    pub fn init() -> Self {
        let args: Vec<CString> = env::args_os().map(|a| { unsafe { CString::from_vec_unchecked(a.into_vec()) }}).collect();
        Self::init_with_command_args(args)
    }
    
    pub fn init_with_command_args(args: Vec<CString>) -> Self {
        verilated::command_args(args);
        TestBench {
            core: U::default(),
            tick_count: 0,
        }
    }

    pub fn reset(&mut self) {
        self.core.reset_up();
        self.core.tick(self.tick_count);
        self.core.reset_down();
    }

    pub fn tick(&mut self) {
        // Increment our own internal time reference
        self.tick_count += 1;

        // Make sure any combinatorial logic depending upon
        // inputs that may have changed before we call tick()
        // have settled before the rising edge of the clock.
        self.core.clock_down();
        self.core.eval();

        // *** Toggle the clock ***

        // Rising edge
        self.core.clock_up();
        self.core.eval();

        // Falling edge
        self.core.clock_down();
        self.core.eval();

        if !self.core.tick(self.tick_count) {
            verilated::set_finish();
        }
    }

    pub fn done(&mut self) -> bool {
        verilated::got_finish()
    }
}
