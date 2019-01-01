require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end
  def self.create(name, grade)
    stud = self.new(name, grade)
    stud.save
    stud
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if @id == nil
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end


  def self.new_from_db(row)
    stud = self.new(row[1],row[2],row[0])
    stud
  end

  def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM students
     WHERE name = ? ;
    SQL
   row = DB[:conn].execute(sql, name)
   self.new_from_db(row[0])
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
