require_relative "../config/environment.rb"

class Student
    attr_accessor :name, :grade, :id

    def initialize(name, grade, id=nil)
      @name = name
      @grade = grade
      @id = id
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
       DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = "DROP TABLE IF EXISTS students"

      DB[:conn].execute(sql)
    end

    def save
      if @id
        self.update
      else
        sql = <<-SQL
        INSERT INTO students (name, grade)
        values(?,?)
        SQL

        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def update
      sql = "UPDATE students SET name = ?, grade = ? where id =?"

      DB[:conn].execute(sql, self.name,self.grade,self.id)
    end

    def self.create(name, grade)
      student = self.new(name,grade)
      student.save
      student
    end

    def self.new_from_db(row)
      student = self.create(row[1],row[2])
      student
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    get = DB[:conn].execute(sql,name)[0]
      Student.new(get[1], get[2],get[0])
    end
end
