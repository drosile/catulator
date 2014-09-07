class Hash
  def symbolize_keys
    dup.symbolize_keys!
  end

  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end

  def recursive_symbolize_keys!
    symbolize_keys!

    values.each do |h|
      h.recursive_symbolize_keys! if h.is_a?(Hash)
    end

    values.select { |v| v.is_a?(Array) }.flatten.each do |h|
      h.recursive_symbolize_keys! if h.is_a?(Hash)
    end

    self
  end
end
