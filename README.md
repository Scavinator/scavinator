# Scavinator

## Contributing

### AI Policy

As a project designed for Scav, the Scav AI policy also applies.

[Rule 10](https://scavhunt.uchicago.edu/assets/lists/2025.pdf):

> AI. Don’t use it

### Dependencies

- [Postgres](https://www.postgresql.org/) is required as a development database. If you do not want to install the database, it's also possible to run in docker. Running in docker is recommend for running the test suite in parallel to speed up test runs.
- Ruby on Rails ([set-up guide here](https://guides.rubyonrails.org/install_ruby_on_rails.html))

### Set-up

1. Run `bundle install` (bundler is installed by ruby) to install dependencies
2. Create a new database in postgres and copy `config/database.sample.yml` to `config/database.yml`. Update the placeholder values appropriately. Load the database schema in from [scavinator-database](https://github.com/Scavinator/scavinator-database).
3. Copy `config/storage.sample.yml` to `config/storage.yml`
4. Set-up your system DNS to point `scavinator.test` and any of its subdomains you need to `127.0.0.1`. This project uses subdomains as a part of its routing decisions so having DNS configured is a requirement.

  Example `/etc/hosts` for linux/MacOS:

  ```
  127.0.0.1 scavinator.test
  127.0.0.1 example.scavinator.test
  127.0.0.1 test.scavinator.test
  127.0.0.1 dev.scavinator.test
  ```

### Running the server

Run `bin/rails server` and visit the site in your browser at `http://scavintor.test:3000`. Create a test team with the same prefix as you've configured in DNS.

### Running tests

Run `bin/rails test`. If you do not have databases configured for parallel testing, set the environment variable `PARALLEL_WORKERS=1`.
