![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)
# Tiny MOS6502
## Multiplex Data and Address Lines
Currently, TinyTapeout only supports 8 inputs, 8 outputs, and 8I/Os (input/outputs). This is a total of 24 pins. The 6502 has 40 pins. To make this work we have to mux some stuff.

The address lines are almost always an output to a memory location, so lets use the 8 output pins to represent this 16 bit binary number. The best technique for the address multiplexing is probably to send the first 8 bits of the address on one clock cyle and then send the top 8 on the next cycle.
So, to control the address lines of this we will have a very basic circuit on the output that takes the 16 bit address and splits it into two 8 bit accesses. We just have to make sure the 6502 clock pulses 1 time for every 2 external clock pulses. Then everything should run smoothly.

The 8 data pins will go on the  I/O lines unmuxed and should fit perfectly. They need to be bidirectional for reads and writes to memory / other peripherals.

The rest of the pins RST, RDY, IRQ, 

The rest of the pins
## MOS 6502 Pinout
        +----+--+----+
     Vss  |1        40 | RST
     RDY  |2        39 | φ2
     φ1   |3        38 | SO
     IRQ  |4        37 | φ0
     NC   |5        36 | NC
     NMI  |6        35 | NC
     SYNC |7        34 | R/W
     Vcc  |8        33 | D0
     A0   |9        32 | D1
     A1   |10       31 | D2
     A2   |11       30 | D3
     A3   |12       29 | D4
     A4   |13       28 | D5
     A5   |14       27 | D6
     A6   |15       26 | D7
     A7   |16       25 | A15
     A8   |17       24 | A14
     A9   |18       23 | A13
     A10  |19       22 | A12
     A11  |20       21 | Vss
          +-----------+

# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://docs.google.com/document/d/1aUUZ1jthRpg4QURIIyzlOaPWlmQzr-jBn3wZipVUPt4)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@matthewvenn](https://twitter.com/matthewvenn)
