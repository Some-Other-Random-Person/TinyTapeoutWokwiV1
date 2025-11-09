# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 31.75, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    dut._log.info("Check VGA sync pulse is present")

    sync_pulse_observed = False
    cycles_to_check = 50_000 
    for i in range(0, cycles_to_check, 20):
        await ClockCycles(dut.clk, 20)
        val = int(dut.uo_out.value)
        if ((val & 0b10000000) != 0):
            sync_pulse_observed = True
            dut._log.info(f"H-sync observed!")


    assert sync_pulse_observed, "VGA output active"