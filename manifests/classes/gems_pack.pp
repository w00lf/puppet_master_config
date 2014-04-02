class gems_pack {
  package { ['bundler', 'murder', 'capistrano', 'bzip2-ruby-rb20', 'unicorn', 'whenever']:
     ensure   => 'installed',
     provider => 'gem',
     source => 'http://rubygems.org'
  }
}