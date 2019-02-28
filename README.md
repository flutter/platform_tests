# Platform testing tools

This repository contains a collection of tools used to measure and test
Flutter's fidelity around platform specific behaviors.

## scroll_overlay

Overlays a Flutter scrollable with a platform scrollable to compare
interactive response.

## transition_curve_finder

A simple tool built for iOS that monitors page position during transition for finding the real animation curve. Data retrieved are saved to a file as points that represent a curve between 0 - 1. It was built for testing the fidelity of current Flutter CupertinoPageRoute animation but it can also be improved for other purposes.

