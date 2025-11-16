# ASCII Donut in x86 TASM

This project is an implementation of the classic rotating 3D ASCII donut, written in x86 assembly using TASM. It renders a spinning torus in the terminal using simple ASCII characters to simulate shading and depth.

The program is inspired by the mathematical explanation of the donut's 3D projection found [here](https://www.a1k0n.net/2011/07/20/donut-math.html).

---

## Features

- **3D Rotation:** Rotates the donut around two axes (`A` and `B` angles) for a smooth animation.
- **ASCII Shading:** Uses luminance characters (`.,-~:;=!*#$@`) to simulate depth and lighting.
- **Z-Buffer:** Handles depth to correctly render overlapping surfaces.
- **Keyboard Exit:** Press any key to exit the program gracefully.

---

## Requirements

- TASM (Turbo Assembler)
- DOSBox or any DOS environment to run the compiled `.exe` program
- VGA-compatible terminal for proper ASCII rendering

---

## Compilation

Assemble the code:

```bash
tasm donut.asm
```
Link the object file:

```bash
tlink donut.obj
```
Run the executable in DOS:

```bash
donut.exe
```

Controls

Press any key: Exit the program