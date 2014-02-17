class String
  def gibberish?
    GibberishDetector.gibberish?(self)
  end
end
