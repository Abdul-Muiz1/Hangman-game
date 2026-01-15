require 'json'

class Hangman
  def initialize
    @secret_word = ""
    @guesses = []
    @lives = 7
    @game_over = false
  end

  def play
    puts "\n--- HANGMAN ---"
    puts "1. New Game"
    puts "2. Load Saved Game"
    print "Choose an option: "
    choice = gets.chomp

    if choice == "2" && File.exist?("saved_game.json")
      load_game
    else
      start_new_game
    end

    # The Main Game Loop
    until @game_over
      display_board
      take_turn
    end
  end

  private

  def start_new_game
    # 1. Load dictionary
    if !File.exist?("google-10000-english-no-swears.txt")
      puts "Error: Dictionary file not found! Please download it."
      exit
    end
    
    dictionary = File.readlines("google-10000-english-no-swears.txt").map(&:chomp)
    
    # 2. Filter for words between 5 and 12 characters
    valid_words = dictionary.select { |word| word.length.between?(5, 12) }
    
    # 3. Pick a random word
    @secret_word = valid_words.sample.upcase
    puts "\nComputer has chosen a random word. Good luck!"
  end

  def display_board
    # Create the visual string (e.g. "_ R O _ R A M")
    display_word = @secret_word.chars.map do |char|
      @guesses.include?(char) ? char : "_"
    end.join(" ")

    puts "\n" + "=" * 20
    puts "Word:  #{display_word}"
    puts "Lives: #{@lives}"
    puts "Used:  #{@guesses.join(', ')}"
    puts "=" * 20
  end

  def take_turn
    print "Guess a letter (or type 'save' to quit): "
    input = gets.chomp.upcase

    # SAVE GAME OPTION
    if input == "SAVE"
      save_game
      puts "Game saved! See you later."
      @game_over = true
      return
    end

    # INPUT VALIDATION
    if input.length != 1 || !input.match?(/[A-Z]/)
      puts "Invalid input! Please type a single letter."
      return
    end

    if @guesses.include?(input)
      puts "You already guessed '#{input}'!"
      return
    end

    # GAME LOGIC
    @guesses << input
    
    if @secret_word.include?(input)
      puts "Good guess!"
    else
      puts "Sorry, '#{input}' is not in the word."
      @lives -= 1
    end

    check_game_over
  end

  def check_game_over
    # WIN CONDITION: All letters in secret_word are in guesses array
    if @secret_word.chars.all? { |char| @guesses.include?(char) }
      display_board
      puts "\nCONGRATULATIONS! You saved the hangman!"
      @game_over = true
      delete_save # Remove save file so they don't load a finished game
      
    # LOSE CONDITION
    elsif @lives == 0
      puts "\nGAME OVER! The word was: #{@secret_word}"
      @game_over = true
      delete_save
    end
  end

  # --- SERIALIZATION METHODS (The "Magic") ---

  def save_game
    # Bundle all necessary data into a Hash
    data = {
      secret_word: @secret_word,
      guesses: @guesses,
      lives: @lives
    }
    
    # Write that Hash to a file as a JSON string
    File.open("saved_game.json", "w") do |file|
      file.write(data.to_json)
    end
  end

  def load_game
    content = File.read("saved_game.json")
    data = JSON.parse(content)

    # Restore the variables from the parsed data
    @secret_word = data["secret_word"]
    @guesses = data["guesses"]
    @lives = data["lives"]
    
    puts "Game loaded! Welcome back."
  end

  def delete_save
    File.delete("saved_game.json") if File.exist?("saved_game.json")
  end
end

# Start the game
game = Hangman.new
game.play
