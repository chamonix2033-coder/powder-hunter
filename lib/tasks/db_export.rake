namespace :db do
  desc "Export data from a source database (e.g. PostgreSQL) to SQLite"
  task export_to_sqlite: :environment do
    require "sqlite3"

    source_url = ENV["SOURCE_DATABASE_URL"] || ENV["DATABASE_URL"]
    if source_url.blank? || source_url.start_with?("sqlite")
      puts "Error: Please provide a PostgreSQL URL in SOURCE_DATABASE_URL environment variable."
      puts "Example: SOURCE_DATABASE_URL=postgres://user:pass@host/db bin/rails db:export_to_sqlite"
      exit 1
    end

    sqlite_path = ENV["TARGET_DB_PATH"] || "production.sqlite3"
    puts "Source: #{source_url.split('@').last} (PostgreSQL)"
    puts "Target: #{sqlite_path} (SQLite)"

    # 1. SQLite ファイルの初期化
    FileUtils.mkdir_p(File.dirname(sqlite_path))
    File.delete(sqlite_path) if File.exist?(sqlite_path)

    # 2. スキーマ作成 (SQLite 接続)
    puts "Connecting to SQLite and loading schema..."
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: sqlite_path)
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

    begin
      load Rails.root.join("db", "schema.rb")
      puts "Schema loaded successfully."
    rescue => e
      puts "Error loading schema: #{e.message}"
      exit 1
    end

    # 3. データのコピー (PostgreSQL 接続)
    puts "Connecting to source (PostgreSQL) to fetch data..."
    ActiveRecord::Base.establish_connection(source_url)

    sqlite_db = SQLite3::Database.new(sqlite_path)
    sqlite_db.execute("PRAGMA foreign_keys = OFF")

    tables = ActiveRecord::Base.connection.tables - [ "schema_migrations", "ar_internal_metadata" ]

    tables.each do |table|
      print "Copying table: #{table}..."

      rows = ActiveRecord::Base.connection.select_all("SELECT * FROM #{table}")
      if rows.empty?
        puts " Empty"
        next
      end

      columns = rows.first.keys
      placeholders = ([ "?" ] * columns.size).join(", ")
      insert_sql = "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{placeholders})"

      sqlite_db.transaction do
        rows.each do |row|
          # SQLite3 gem doesn't handle Ruby Time/Date/Boolean objects in execute()
          # We need to convert them to strings or integers.
          converted_values = row.values.map do |val|
            case val
            when Time, DateTime
              val.iso8601(6)
            when Date
              val.to_s
            when true
              1
            when false
              0
            else
              val
            end
          end
          sqlite_db.execute(insert_sql, converted_values)
        end
      end
      puts " Done (#{rows.length} rows)"
    end

    sqlite_db.execute("PRAGMA foreign_keys = ON")
    sqlite_db.close

    puts "\nSuccess! SQLite database created at #{sqlite_path}"

    # Summary
    puts "\n--- Summary ---"
    sqlite_db_check = SQLite3::Database.new(sqlite_path)
    [ "users", "comments", "ski_resorts" ].each do |t|
      count = sqlite_db_check.get_first_value("SELECT count(*) FROM #{t}") rescue "N/A"
      puts "#{t}: #{count} rows"
    end
    sqlite_db_check.close

    puts "\nNext steps:"
    puts "1. fly sftp put #{sqlite_path} /data/production.sqlite3 -a powder-hunter-sqlite"
    puts "2. fly apps restart powder-hunter-sqlite"
  end
end
