# wait-for-x11

Wait for the specified X11 server to be ready.

## Usage

```console
$ wait-for-x11 --help
Wait for the specified X11 server to be ready.

Usage:
  wait-for-x11 [options] [--] [<command> [<argument>...]]
  wait-for-x11 --help
  wait-for-x11 --version

Options:
  --help                      Show this help and exit.
  --version                   Show version and exit.
  --display string            The X11 server display to connect to (or the
                              DISPLAY environment variable if not given)
                              [default: $DISPLAY].
  --max-retries int           The maximum number of times to test whether X11
                              server is ready, use 0 to allow unlimited retries
                              [default: 10].
  --retry-interval duration   Time between running retries (s|m|h|d), the
                              suffix is 's' if not given [default: 1s].

Environment:
  DISPLAY                     The X11 server display to connect to.
```
