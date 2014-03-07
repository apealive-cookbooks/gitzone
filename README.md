# gitzone cookbook

Chef cookbook for git-shell managed BIND zone files.
The gitzone scripts are developed by the [dyne.org](https://github.com/dyne/gitzone).

NOTE: This cookbook is in DRAFT stage. Even the best practices are applied some conceptual failures may exist.

Pull requests & suggestions are welcome.

## Supported Platforms

Tested on:

* ubuntu 12.04
* centos 6.4

Acknowledgement:
* On centos 6.4 is small issue with git < 1.7. It's described here: https://github.com/dyne/gitzone/issues/1
* At the present time, there is the small inconvenience that zone files are not deployed, until manual push from cloned repository.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitzone']['preffix']</tt></td>
    <td>String</td>
    <td>gitzone install preffix</td>
    <td><tt>/usr</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['home']</tt></td>
    <td>String</td>
    <td>where to create gitzone home dir</td>
    <td><tt>/home</tt></td>
  </tr>
    <td><tt>['gitzone']['bind_repos_dir']</tt></td>
    <td>String</td>
    <td>Path where are bind configuration files reffering to gitzone repo are stored</td>
    <td><tt>/etc/bind/repo</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['user']</tt></td>
    <td>String</td>
    <td>gitzone system user to be created</td>
    <td><tt>gitzone</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['group']</tt></td>
    <td>String</td>
    <td>gitzone system group for gitzone user</td>
    <td><tt>g</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['user_ssh_pub_keys']</tt></td>
    <td>String</td>
    <td>ssh keys to be stored in authorized_keys (for remote access or dyn DNS feature)</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['admin']</tt></td>
    <td>String</td>
    <td>system account where the repo clone is first created</td>
    <td><tt>nil, by default uses gitzone_user home dir</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['domains']</tt></td>
    <td>Array</td>
    <td>2nd level domain names to be created/searched</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['repo_url']</tt></td>
    <td>String</td>
    <td>where to clone gitzone code</td>
    <td><tt>https://github.com/dyne/gitzone.git"</tt></td>
  </tr>
  <tr>
    <td><tt>['gitzone']['repo_dir']</tt></td>
    <td>String</td>
    <td>where to clone gitzone source code</td>
    <td><tt>/srv/repos/git</tt></td>
  <tr>
  <tr>
    <td><tt>['gitzone']['repos']</tt></td>
    <td>String</td>
    <td>extends gitzone.conf $repos configuration</td>
    <td><tt></tt></td>
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

### Managing zone files

```bash
su - bob
git clone gitzone@localhost:zones/gitzone gitzone-admin
cd gitzone-admin
#edit zone files
git checkout master
git commit -am "updates"
git pull --rebase origin master
git push origin master
git pull
```

### Dynamic DNS feature

TBD: Not yet tested. See original gitzone repository for usage details.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Petr Michalec (<epcim@apealive.net>)
