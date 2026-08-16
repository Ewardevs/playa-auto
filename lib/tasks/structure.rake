# Keeps db/structure.sql loadable on older PostgreSQL servers.
#
# pg_dump writes the SET options its own version knows about. A newer client
# against an older server (pg_dump 18 dumping for a PostgreSQL 16 server, for
# example) emits `SET transaction_timeout = 0`, which the server then rejects
# with "unrecognized configuration parameter" — and `db:prepare` fails on a
# fresh checkout.
#
# These options carry no schema meaning, so they are stripped after every dump.
namespace :db do
  UNPORTABLE_SETTINGS = %w[
    transaction_timeout
    idle_session_timeout
  ].freeze

  task :normalize_structure do
    path = Rails.root.join("db/structure.sql")
    next unless path.exist?

    pattern = /\ASET (#{UNPORTABLE_SETTINGS.join('|')}) =/
    original = path.read
    cleaned  = original.lines.reject { |line| line.match?(pattern) }.join

    path.write(cleaned) unless cleaned == original
  end
end

Rake::Task["db:schema:dump"].enhance { Rake::Task["db:normalize_structure"].invoke }
