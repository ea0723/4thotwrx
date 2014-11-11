class Conversion < ActiveRecord::Base

  validates_presence_of :convert_me, presence: true, length: { maximum: 100 }
  validate :input_valid
  after_validation :clean_it_up, :simplify_for_conversion
  before_create :map_it, :calculate_it

  @units = []
  @metals = 1

  VALID_MATCH_WORDS = ['glob', 'prok', 'pish', 'tegj', 'iron', 'silver', 'gold']
  MATCH_UNITS = { 'tegj' => 'L', 'pish' => 'X', 'prok' => 'V', 'glob' => 'I', 'gold' => 14450, 'iron' => 195.50, 'silver' => 17}

  def question_how_many(question="")
	  extract_invalid_words($1) if question.match(/^how many credits is (.+?)$/i)
  end

  def question_how_much(question="")
	  extract_invalid_words($1) if question.match(/^how much is (.+)$/i)
  end

  def unit_is_value(question="")
	  extract_invalid_words($1) if question.match(/^(\w+?) is \w\s?$/i)
  end

  def units_plus_credits(question="")
    extract_invalid_words($1) if question.match(/^(.+?) is \d+ credits$/i)
  end

  def units_only(question="")
	  words = question.split
    words.delete_if { |word| !VALID_MATCH_WORDS.include?(word) }
    words.length == question.split.length ? words : nil
  end


  def input_valid
    matched_words = question_how_many(self.convert_me) || question_how_much(self.convert_me) || unit_is_value(self.convert_me) || units_plus_credits(self.convert_me) || units_only(self.convert_me)

    logger.info "********** input_valid response ---> matched_words: #{matched_words} **********"

    errors.add(:convert_me, "I have no idea what you are talking about") && errors.add(:convert_me, "(but The Answer to The Question is, ultimately, 42)") if matched_words.nil? || matched_words == []
    
  end

  def clean_it_up
    self.convert_me.downcase!
    self.convert_me.strip!
    if self.convert_me.match(/\?$/)
      self.convert_me.chop!
      logger.info "here's the string after clean_it_up --> #{convert_me}"
    end
  end


	def simplify_for_conversion 
    self.convert_me.gsub!(/how many credits is\s/i, '')
    self.convert_me.gsub!(/how much is\s/i, '')
    self.convert_me.gsub!(/\sis \d+ credits/i, '')
    if self.convert_me.match(/^(glob is I)|(prok is V)|(pish is X)|(tegj is L)/i)
      self.convert_me.gsub!(/\sis \w$/i, '')
    end
    @units = self.convert_me.strip.split(" ")

  end


  def map_it
    if @units[1] == 'is'
	    @units.pop(2)
      puts("here are the units to map --> #{@units}")
    end
      @units.map! { |a| MATCH_UNITS[a] }
      @units.length <= 1 || @units[-1].is_a?(String) || @units.empty? ? @metals = 1 : @metals = @units.pop
      puts("this is the metals --> #{@metals}")
      @joined = @units.join('')
      puts("this is the joined array for final calculation --> #{@joined}")
  end


  def calculate_it
    total = 0
    add = 0
      puts("this is the starting total --> #{total}")
      until @joined.empty? do
        case
          when @joined.start_with?('L') then add += 50; len = 1
          when @joined.start_with?('XL') then add += 40; len = 2
          when @joined.start_with?('X') then add += 10; len = 1
          when @joined.start_with?('IX') then add += 9; len = 2
          when @joined.start_with?('V') then add += 5; len = 1
          when @joined.start_with?('IV') then add += 4; len = 2
          when @joined.start_with?('I') then add += 1; len = 1
          else
            add = 0
        end
        @joined.slice!(0, len)
      end
      puts("i have added a value --> #{add}")
      total += add
      total *= @metals
      puts("the total is now --> #{total}")
      self.credits = total
  end

  private
  def extract_invalid_words(sentence="")
    words = sentence.split
    words.delete_if { |word| !VALID_MATCH_WORDS.include?(word) }
    words.count > 0 ? words : nil
  end

end

