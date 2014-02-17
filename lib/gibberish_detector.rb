require 'yaml'
require 'gibberish_detector/version'
require 'string'

class GibberishDetectorException < Exception ; end

class GibberishDetector
  ACCEPTED_CHARACTERS = 'abcdefghijklmnopqrstuvwxyz ';
  DATA_FILE = File.join(File.dirname(__FILE__), '..', '.trained_data.yml')

  class << self
    def gibberish?(text, opts = {})
      opts[:lib_path] ||= DATA_FILE
      opts[:raw] ||= false

      raise GibberishDetectorException, "Please run Gibberish.train! to build your trained data file." unless File.exist?(opts[:lib_path])

      trained_library = YAML.load(File.open(opts[:lib_path]))
      raise GibberishDetectorException, 'Please run Gibberish.train! to build your trained data file.' if trained_library.nil?

      value = _averageTransitionProbability(text, trained_library[:matrix])
      return value if opts[:raw] == true

      return true if value <= trained_library[:threshold]

      false
    end

    def train!(opts={})
      opts[:big_text_file] = 'big.txt'
      opts[:good_text_file] = 'good.txt'
      opts[:bad_text_file] = 'bad.txt'
      opts[:lib_path] = DATA_FILE

      if File.exist?(opts[:big_text_file]) == false || File.exist?(opts[:good_text_file]) == false || File.exist?(opts[:bad_text_file]) == false
        raise GibberishDetectorException, "We couldn't find one of #{opts[:big_text_file]}, #{opts[:good_text_file]} or #{opts[:bad_text_file]}.  Please ensure all three files exist before training."
        return false
      end

      k = ACCEPTED_CHARACTERS.length
      hsh = {}
      pos = ACCEPTED_CHARACTERS.dup.split('').each_with_index do |key, index|
        hsh[key] = index
      end.reverse
      pos = hsh

      log_prob_matrix = {}
      range = (0...k).to_a
      range.each do |index|
        arr = {}
        range.each do |index2|
          arr[index2] = 10
        end

        log_prob_matrix[index] = arr
      end

      lines = File.open(opts[:big_text_file]).read
      lines.each_line do |line|
        filtered_line = normalize(line).split('')
        a = false
        filtered_line.each do |b|
          if a != false
            log_prob_matrix[pos[a]] ||= {}
            log_prob_matrix[pos[a]][pos[b]] ||= 0
            log_prob_matrix[pos[a]][pos[b]] += 1
          end
          a = b
        end
      end

      log_prob_matrix.each do |i, row|
        s = row.values.inject(:+).to_f
        row.each do |k, j|
          log_prob_matrix[i][k] = Math.log(j / s)
        end
      end

      good_lines = File.open(opts[:good_text_file]).read
      good_probs = []
      good_lines.each_line do |line|
        good_probs << _averageTransitionProbability(line.chomp, log_prob_matrix)
      end

      bad_lines = File.open(opts[:bad_text_file]).read
      bad_probs = []
      bad_lines.each_line do |line|
        bad_probs << _averageTransitionProbability(line.chomp, log_prob_matrix)
      end

      min_good_probs = good_probs.min
      max_bad_probs = bad_probs.max

      if min_good_probs <= max_bad_probs
        raise GibberishDetectorException, "The prob counts are invalid."
      end

      threshold = (min_good_probs + max_bad_probs) / 2
      File.open(opts[:lib_path], 'w+') do |file|
        data = {
          :matrix => log_prob_matrix,
          :threshold => threshold
        }

        file << data.to_yaml
      end
    end

    private
      def normalize(text)
        text.downcase.gsub(/[^a-z\ ]/, '')
      end

      def _averageTransitionProbability(line, log_prob_matrix)
        log_prob = 1.0
        transition_ct = 0

        hsh = {}
        ACCEPTED_CHARACTERS.dup.split('').each_with_index do |key, index|
          hsh[key] = index
        end.reverse
        pos = hsh

        filtered_line = normalize(line.dup).split('')
        a = false
        filtered_line.each do |b|
          if a != false
            log_prob += log_prob_matrix[pos[a]][pos[b]]
            transition_ct += 1
          end

          a = b
        end

        Math.exp(log_prob / [transition_ct, 1].max)
      end
  end
end

