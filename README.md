# :lock: CIS Debian 12 Apache 2.4 Hardening


Modular Debian 12 Apache 2.4 security hardening scripts based on [cisecurity.org](https://www.cisecurity.org)
recommendations and [OVH debian 10/11/12 CIS Hardening](https://github.com/ovh/debian-cis)

These scripts have been tested on Debian 12, but they should work on Debian 10 or 11

```console
$ bin/hardening.sh --audit-all
[...]
hardening                 [INFO] Treating /opt/apache2.4-cis/bin/hardening/3.4_directories_owned_by_root.sh
3.4_directories_owned_by_ [INFO] Working on 3.4_directories_owned_by_root
3.4_directories_owned_by_ [INFO] [DESCRIPTION] Ensure Apache Directories and Files Are Owned By Root
3.4_directories_owned_by_ [INFO] Checking Configuration
3.4_directories_owned_by_ [INFO] Performing audit
3.4_directories_owned_by_ [ OK ] Directory /etc/apache2/ : all files are owned by root
3.4_directories_owned_by_ [ OK ] Directory /usr/lib/apache2/ : all files are owned by root
3.4_directories_owned_by_ [ OK ] Directory /var/lib/apache2/ : all files are owned by root
3.4_directories_owned_by_ [ OK ] Directory /usr/share/apache2/ : all files are owned by root
3.4_directories_owned_by_ [ OK ] Check Passed
[...]
################### SUMMARY ###################
      Total Available Checks : 72
         Total Runned Checks : 72
         Total Passed Checks : [   40/72 ]
         Total Failed Checks : [   32/72 ]
   Enabled Checks Percentage : 100.00 %
       Conformity Percentage : 55.55 %
```

## :dizzy: Quickstart

```console
$ git clone https://github.com/ulzbug/apache2.4-cis && cd apache2.4-cis
$ cp debian/default /etc/default/apache2-cis-hardening
$ sed -i "s#CIS_LIB_DIR=.*#CIS_LIB_DIR='$(pwd)'/lib#" /etc/default/apache2-cis-hardening
$ sed -i "s#CIS_CHECKS_DIR=.*#CIS_CHECKS_DIR='$(pwd)'/bin/hardening#" /etc/default/apache2-cis-hardening
$ sed -i "s#CIS_CONF_DIR=.*#CIS_CONF_DIR='$(pwd)'/etc#" /etc/default/apache2-cis-hardening
$ sed -i "s#CIS_TMP_DIR=.*#CIS_TMP_DIR='$(pwd)'/tmp#" /etc/default/apache2-cis-hardening
$ ./bin/hardening/2.2_enable_log_config_module.sh --audit
2.2_enable_log_config_mod [INFO] Working on 2.2_enable_log_config_module
2.2_enable_log_config_mod [INFO] [DESCRIPTION] Ensure the Log Config Module Is Enabled
2.2_enable_log_config_mod [INFO] Checking Configuration
2.2_enable_log_config_mod [INFO] Performing audit
2.2_enable_log_config_mod [ OK ] log_config is enabled!
2.2_enable_log_config_mod [ OK ] Check Passed
```

## :hammer: Usage

### Configuration

Hardening scripts are in ``bin/hardening``. Each script has a corresponding
configuration file in ``etc/conf.d/[script_name].cfg``.

Each hardening script can be individually enabled from its configuration file.
For example, this is the default configuration file for ``disable_system_accounts``:

```
# Configuration for script of same name
status=disabled
# Put here your exceptions concerning admin accounts shells separated by spaces
EXCEPTIONS=""
```

``status`` parameter may take 3 values:
- ``disabled`` (do nothing): The script will not run.
- ``audit`` (RO): The script will check if any change *should* be applied.

Global configuration is in ``etc/hardening.cfg``. This file controls the log level
as well as the backup directory. Whenever a script is instructed to edit a file, it
will create a timestamped backup in this directory.

### Run aka "Harden your distro"

To run the checks and apply the fixes, run ``bin/hardening.sh``.

This command has 2 main operation modes:
- ``--audit``: Audit your system with all enabled and audit mode scripts
- ``--apply``: Audit your system with all enabled and audit mode scripts and apply changes for enabled scripts ( not implemented )

Additionally, some options add more granularity:

 ``--audit-all`` can be used to force running all auditing scripts,
including disabled ones. this will *not* change the system.

``--audit-all-enable-passed`` can be used as a quick way to kickstart your
configuration. It will run all scripts in audit mode. If a script passes,
it will automatically be enabled for future runs. Do NOT use this option
if you have already started to customize your configuration.

``--sudo``: audit your system as a normal user, but allow sudo escalation to read
specific root read-only files. You need to provide a sudoers file in /etc/sudoers.d/
with NOPASWD option, since checks are executed with ``sudo -n`` option, that will
not prompt for a password.

``--batch``: while performing system audit, this option sets LOGLEVEL to 'ok' and
captures all output to print only one line once the check is done, formatted like :
OK|KO OK|KO|WARN{subcheck results} [OK|KO|WARN{...}]

``--only <check_number>``: run only the selected checks.

``--set-hardening-level``: run all checks that are lower or equal to the selected level.
Do NOT use this option if you have already started to customize your configuration.

``--allow-service <service>``: use with --set-hardening-level. Modifies the policy
to allow a certain kind of services on the machine, such as http, mail, etc.
Can be specified multiple times to allow multiple services.
Use --allow-service-list to get a list of supported services.

``--set-log-level <level>``: This option sets LOGLEVEL, you can choose : info, warning, error, ok, debug.
Default value is : info

``--create-config-files-only``: create the config files in etc/conf.d. Must be run as root,
before running the audit with user secaudit, to have the rights setup well on the conf files.

``--allow-unsupported-distribution``: must be specified manually in the command line to allow
the run on non compatible version or distribution. If you want to mute the warning change the
LOGLEVEL in /etc/hardening.cfg


## :heavy_exclamation_mark: Disclaimer

This project is a set of tools. They are meant to help the system administrator
built a secure environment. While we use it to harden our PCI-DSS compliant
infrastructure, we can not guarantee that it will work for you. It will not
magically secure any random host.

A word about numbering, implementation and sustainability over time of this repository:
This project is born with the Debian 7 distribution in 2016. Over time, CIS Benchmark PDF
has evolved, changing it's numbering, deleting obsolete checks.
In order to keep retro-compatiblity with the last maintained Debian, the numbering
has not been changed along with the PDF, because the configuration scripts are named after it.
Changing the numbering might break automation for admins using it for years, and handling
this issue without breaking anything would require a huge refactoring.
As a consequence, please do not worry about numbering, the checks are there,
but the numbering accross PDFs might differ.
Please also note that all the check inside CIS Benchmark PDF might not be implemented
in this set of scripts.
We did choose the most relevant to us, do not hesitate to make a
Pull Request in order to add the missing script you might find relevant for you.

Additionally, quoting the License:

> THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY
> EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY
> DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
> LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
> ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## :satellite: Reference

- **Center for Internet Security**: https://www.cisecurity.org/
- **CIS recommendations**: https://learn.cisecurity.org/benchmarks
- **OVH Debian CIS**: https://github.com/ovh/debian-cis

## :page_facing_up: License

Apache, Version 2.0
