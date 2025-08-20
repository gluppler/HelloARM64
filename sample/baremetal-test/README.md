# Bare-Metal Test

This sample is a minimal, pure assembly program to test your bare-metal toolchain.

### To Build and Run:

```bash
# This command works on both macOS and Linux
make bare file=sample/baremetal-test/hello-bare.s
````

Then, run the executable:

```bash
./bin/hello-bare
```

You should see "Hello Bare-Metal\!" printed to your console.
