# euromillions.sh

> EuroMillions Checker from the command-line

Discover whether you are a EuroMillions winner by comparing your numbers against the results from the past 180 days.

`euromillions.sh` is a simple shell script using the [draw history](https://www.national-lottery.co.uk/results/euromillions/draw-history/csv) of [national-lottery.co.uk](https://www.national-lottery.co.uk/) as a data source.

<!-- ![euromillions.sh](https://raw....) -->

## Usage

```sh
# Install
$ curl -o ticker.sh https://raw.githubus....

# Allow execution
chmod 770 ./euromillions.sh

# Run by passing as arguments your 5 ball numbers and 2 Lucky Stars at the end
./euromillions.sh 5 7 8 16 20 2 12
```