require 'rails_helper'

RSpec.describe DiffParser, type: :service do
  let(:content) { Rails.root.join("spec/support/files/#{file}").expand_path }
  let(:parser) { described_class.new(content: content) }

  let(:result) { result_array.map { |line| DiffParser::Line.new(content: line[0], state: line[1], index: line[2], original_index: line[3], changed_index: line[4]) } }

  subject { parser.call }

  describe '#call' do
    context 'empty diff' do
      let(:content) { '' }

      let(:result_array) { [] }

      it { expect(subject).to eq(result) }
    end

    context 'simple diff' do
      let(:file) { 'diff_simple.diff' }

      let(:result_array) do
        [
          ["@@ -1,1 +1,1 @@\n", 'range', 1, nil, nil],
          ["-a\n", 'removed', 2, 1, nil],
          ["+b\n", 'added', 3, nil, 1]
        ]
      end

      it 'parses correctly' do expect(subject).to eq(result) end
    end

    context 'diff with no newline comments' do
      let(:file) { 'diff_with_no_newline_comments.diff' }

      let(:result_array) do
        [
          ["@@ -1,1 +1,1 @@\n", 'range', 1, nil, nil],
          ["-a\n", 'removed', 2, 1, nil],
          ["\\ No newline at end of file\n", 'comment', 3, nil, nil],
          ["+b\n", 'added', 4, nil, 1],
          ["\\ No newline at end of file\n", 'comment', 5, nil, nil]
        ]
      end

      it 'parses correctly' do expect(subject).to eq(result) end
    end
  end
end