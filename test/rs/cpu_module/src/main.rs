extern crate test_bench;

mod ffi {
    use std::os::raw::c_uchar;

    #[allow(non_camel_case_types)]
    pub enum cpu_top {}

    extern "C" {
        pub fn cpu_top_new() -> *mut cpu_top;
        pub fn cpu_top_delete(cpu_top: *mut cpu_top);
        pub fn cpu_top_eval(cpu_top: *mut cpu_top);
        // pub fn cpu_top_final(cpu_top: *mut cpu_top);
        pub fn cpu_top_clk_i(cpu_top: *mut cpu_top, input: c_uchar);
        pub fn cpu_top_rst_i(cpu_top: *mut cpu_top, input: c_uchar);
        pub fn cpu_top_count_o(cpu_top: *mut cpu_top) -> c_uchar;
    }
}

pub struct CpuTop(*mut ffi::cpu_top);

impl Default for CpuTop {
    fn default() -> Self {
        let ptr = unsafe { ffi::cpu_top_new() };
        assert!(!ptr.is_null());
        CpuTop(ptr)
    }
}

impl Drop for CpuTop {
    fn drop(&mut self) {
        unsafe {
            ffi::cpu_top_delete(self.0);
        }
    }
}

impl test_bench::Module for CpuTop {
    type Uut = CpuTop;

    fn tick(&mut self, tick_count: usize) -> bool {
        if tick_count > 10 {
            return false;
        }

        println!("{}: count_o = {}", tick_count, self.count());
        
        true
    }

    fn eval(&mut self) {
        unsafe {
            ffi::cpu_top_eval(self.0);
        }
    }

    fn clock_up(&mut self) {
        unsafe {
            ffi::cpu_top_clk_i(self.0, 1);
        }
    }

    fn clock_down(&mut self) {
        unsafe {
            ffi::cpu_top_clk_i(self.0, 0);
        }
    }

    fn reset_up(&mut self) {
        unsafe {
            ffi::cpu_top_rst_i(self.0, 1);
        }
    }

    fn reset_down(&mut self) {
        unsafe {
            ffi::cpu_top_rst_i(self.0, 0);
        }
    }
}

impl CpuTop {
    pub fn count(&self) -> u8 {
        unsafe { ffi::cpu_top_count_o(self.0) }
    }
}

fn main() {
    type TestBench = test_bench::TestBench<CpuTop>;
    let mut tb = TestBench::init();
    while !tb.done() {
        tb.tick();
    }
}
