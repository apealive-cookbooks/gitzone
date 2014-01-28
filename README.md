# gitzone cookbook

Chef cookbook for git-shell managed BIND zone files.
The gitzone scripts are developed by the [dyne.org](https://github.com/dyne/gitzone).

NOTE: This cookbook is in DRAFT stage. Even the best practices are applied some conceptual failures
may exist. Be aware that current recipes and the whole concepts might change until final version.

Pull requests & suggestions are welcome.

## Supported Platforms

Tested on:

* ubuntu 12.04.

(Should work on the other distro as well.)


## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitzone']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### gitzone::default

Include `gitzone` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gitzone::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Petr Michalec (<epcim@apealive.net>)
