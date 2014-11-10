class Conversion < ActiveRecord::Base

  validates_presence_of :convert_me, presence: true, length: { maximum: 100 }
  validate :input_valid
  validate :clean_it_up
  before_create :map_it
  before_create :calculate_it

# Step 1) validate that the input contains nothing outside the accepted input to nullify calculation if not necessary

  @valid_words = Regexp.union(/glob|prok|pish|tegj|how much is|how many credits is|\sis\s\d+\scredits\z|\bI\b|\bV\b|\bX\b|\bL\b/i)
  @units = []
  @metals = 1

  def input_valid
    self.convert_me do
      unless self.convert_me.scan(@valid_words) 
        errors.add(:convert_me, 'I have no idea what you are talking about')
      end
    end
  end

# Step2) clean up the string for conversion

  # start by remove any ending spaces and punctuation
  def clean_it_up
    self.convert_me.downcase!
    if self.convert_me.match(/\?\s*$/)
      self.convert_me.chop!
      puts("here's the string --> #{convert_me}")
    end
    # next, remove any leading or tailing strings
    if self.convert_me.scan(/\A(how many credits is\s)/i)
      self.convert_me.gsub!(/\A(how many credits is\s)/i, '')
      puts("here's the simplified string for splitting --> #{convert_me}")
    end
    if self.convert_me.scan(/\A(how much is\s)/i)
      self.convert_me.gsub!(/\A(how much is\s)/i, '')
      puts("here's the simplified string for splitting --> #{convert_me}")
    end
    if self.convert_me.scan(/(is \d+ credits)\z/i)
      self.convert_me.gsub!(/(is \d+ credits)\z/i, '')
      puts("here's the simplified string for splitting --> #{convert_me}")
    end
    if self.convert_me.match(/\A(glob is I)|(prok is V)|(pish is X)|(tegj is L)/i)
      self.convert_me.gsub!(/\A\sis\s./i, '')
      puts("here's the simplified string for splitting --> #{convert_me}")
    end
    # finally, convert input string to an array
    @units = convert_me.split(" ")
    puts("Here's the split string --> #{@units}")
  end


# Step 3) strip any leading words if they got through step 2. Map the units to Roman Numerals or integer for ease of assessment. Break out the metals. Convert to integers
  def map_it
    if @units[1] == 'is' then @units.pop(2)
    end
    @units.map! { |a|
      if a == 'glob' then a = 'I'
      elsif a == 'prok' then a = 'V'
      elsif a == 'pish' then a = 'X'
      elsif a == 'tegj' then a = 'L'
      elsif a == 'gold' then a = 14450
      elsif a == 'iron' then a = 195.50
      elsif a == 'silver' then a = 17
      # return an error as a backup if anything got through the validation
      else
        self.credits = 'I have no idea what you are talking about'
      end
    }
    # separate out the "metals" for multiplication
    @units.length <= 1 || @units[-1].is_a?(String) ? @metals = 1 : @metals = @units.pop
      puts("this is the metals --> #{@metals}")
    @joined = @units.join('')
      puts("this is the joined array --> #{@joined}")
  end

  def calculate_it
    @total = 0
    @add = 0
      puts("this is the starting total --> #{@total}")
  # convert units from roman numerals to integers & multiply by metals to get final credit amount. Raise exception if invalid numeral pair
    if self.credits == nil
      until @joined.empty? do
        case
          when @joined.start_with?('L') then @add += 50; len = 1
          when @joined.start_with?('XL') then @add += 40; len = 2
          when @joined.start_with?('X') then @add += 10; len = 1
          when @joined.start_with?('IX') then @add += 9; len = 2
          when @joined.start_with?('V') then @add += 5; len = 1
          when @joined.start_with?('IV') then @add += 4; len = 2
          when @joined.start_with?('I') then @add += 1; len = 1
          else
            @add = 0
            errors.add(:convert_me, 'I have no idea what you are talking about')
        end
        @joined.slice!(0, len)
      end
      puts("i have added a value --> #{@add}")
    end
    @total += @add
    @total *= @metals
      puts("the total is now --> #{@total}")
    self.credits = @total
  end

end

