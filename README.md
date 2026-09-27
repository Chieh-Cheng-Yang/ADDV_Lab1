# ADDV Lab 1 - Asynchronous FIFO

## Project Structure

```
RTL/
    RTL source files and testbench

RTL_noTB/
    RTL source files only (used for synthesis)

sim/
    Makefile

synth/
    Makefile
    compile_dc.tcl

env.cshrc
```

## Simulation

1. type tcsh

2. Source the environment.

```
source env.cshrc
```

3. Go to the simulation directory.

```
cd sim
```

4. Compile the design.

```
make compile_verdi
```

5. Run simulation.

```
make sim
```

6. Open Verdi waveform.

```bash
make waves_verdi
```

---

## Synthesis

1. Go to the synthesis directory.

```
cd ../synth
```

2. Run Design Compiler.

```
make synth
```
