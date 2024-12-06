# hdmonitor
Shell script to monitor HD temperature (and shutdown the server if needed)

# HD MONITOR

> Bash script to monitor HD temperature (and shutdown the server if needed)
>
> Usage: for example add crontab command to monitor temperature
>
> `*/4 * * * * root /path/to/script/s_hddtemp-monitor.sh > /dev/null 2>&1`

&nbsp;
![](https://img.shields.io/badge/Made%20with%20love%20and%20with-bash-blue) [![MIT license](https://img.shields.io/badge/License-MIT-green.svg)](https://lbesson.mit-license.org/)

## Stack

- Require hddtemp installed: "sudo apt install hddtemp"

- Require notify-send installed (default on ubuntu/debian)

- Optional smtp softare as ssmtp

## Usage

sh s_hddtemp-monitor.sh

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Authors and acknowledgment

**Lorenzo "Saibal" Forti** - <lorenzo.forti@gmail.com>

## DevTeam

### ARMADA 429

* Lorenzo "Saibal" Forti

## License

[MIT](https://choosealicense.com/licenses/mit/)
![](https://img.shields.io/badge/License-Copyleft%20Saibal%20--%20All%20Rights%20Reserved-red)
