Linux boot exploration template
===============================

This project serves as a template to explore and debug kickstart files and boot options in a development/test environment. This setup avoid using real servers, and the drawbacks that come associated with them, ie long waits for servers to boot, manually having to type the options at boot, or just minimize breaking servers.

The project relies on [Packer.io](https://www.packer.io) to simulate a PXE boot and apply boot options and call a specific kickstart. The specific examples here use [VirtualBox](https://www.virtualbox.org) as the provider of VMs, but you might want to use a different provider supported by Packer.

For the impatient
-----------------

`packer build -force templates/main.json`

Example scenario
----------------

The example scenario provided in this project is the following: `We would like to investigate how to install or update a driver before the installation of a Linux OS begins.`

To that end we explore the use of the `inst.dd` boot option and the `driverdisk` kickstart option to upgrade a `hpsa` driver to CentOS 7.2 on boot. Three Packer builders are set in `template/main.json`:
- `centos72` is a standard CentOS 7.2.1511 boot, which is known to contain the `hpsa 3.4.10-0-RH1` driver, although it is not loaded in the kernel.
- `centos72dd` uses the `inst.dd` boot option to upgrade the `hpsa` driver to version `3.4.20-100`, which will also load it in the kernel as part of the upgrade.
- `centos72ks` uses the `driverdisk` kickstart option to also upgrade the `hpsa` driver to version `3.4.20-100` and load it in the kernel.

Note that `centos72` and `centos72dd` both use the kickstart file found in `http/kickstart1.ks`, while `centos72ks` uses `http/kickstart2.ks`.

This scenario depends on two external dependencies, the ISO file to boot from and the updated RPM for the `hpsa` driver, both publicly available.

Template features
-----------------

The Packer template used in this project is specifically designed to explore boot and kickstart options and more specifically for the scenario stated above. We try to simplify the setup by reducing the complexity of the kickstart files and the boot setup. Feel free to adapt it to your needs as well as add/remove builders or other Packer options.

The following is a list of specific changes that we think might help debugging scenarios like this:
- Builders don't produce an artifact. Look for `skip_export` in the template to change this behavior.
- There is no special provisioning of machines, and the kickstart files are minimal (ie only install `@core` packages).
- The kickstart sets a root password in clear text (`packer`), in case we need to further explore the installation process.
- The template sets two 1 hour timeouts to give us time to explore:
  - First, it will wait 1 hour while booting, allowing us to explore the booting and installation process, ie drop into a terminal at `pre` and `post` installation stages. This timeout can be tweaked by the `ssh_timeout` setting on each builder.
  - Second, it will wait 1 hour after the installation is done and the machine has rebooted. This can be helpful to explore the installation has gone as expected. This timeout occurs at the provisioning stage (see `pause_before`), and changing this setting will affect all builders.
- The kickstart files provided contain some code to explore the drivers installed and loaded in the kernel in the `pre` installation stage. First, we report the state of the `hpsa` and `sg` drivers. Then, after pressing `Enter`, we drop into a shell to do further manual exploration. Once we exit from the shell, the installation process will continue. Note that we have 1 hour to explore at this stage (see first timeout above). You will need to adapt this `pre` section and the `post` installation stage to your needs.

Packer
------

Packer ships as a binary, [download](https://www.packer.io/downloads.html) and install it in your path. To start running type:

`packer build -force templates/main.json`

Note the use of the `-force` option. Even though we are not producing artifacts (see above), Packer still creates the output directory and will fail to run if the output directory is present. If you need the artifacts and change the template accordingly, you might need to be more careful when using the `-force` option. You can find more about this and other command line options [here](https://www.packer.io/docs/commands/build.html).

You can find more about Packer in their excellent [documentation](https://www.packer.io/docs) site. The following is a list of components used by this project:
- [VirtualBox Builder from an ISO](https://www.packer.io/docs/builders/virtualbox-iso.html)
- [SSH Communicator](https://www.packer.io/docs/templates/communicator.html#ssh)
- [Shell Provisioner](https://www.packer.io/docs/provisioners/shell.html)

License
-------

Released under the [MIT license](https://opensource.org/licenses/MIT).

Author Information
------------------

Luis Gracia while at [The Rockefeller University](https://www.rockefeller.edu):
- lgracia [at] rockefeller.edu
- GitHub at [luisico](https://github.com/luisico)
