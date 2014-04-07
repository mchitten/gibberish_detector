class String
  def gibberish?
    GibberishDetector.gibberish?(self)
  end

  def gibberishness
    1 - GibberishDetector.gibberish?(self, raw: true)
  end
end
