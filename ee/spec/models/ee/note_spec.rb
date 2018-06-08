require 'spec_helper'

describe EE::Note do
  # Remove with https://gitlab.com/gitlab-org/gitlab-ee/issues/6347
  describe "#note and #note_html overrides for weight" do
    using RSpec::Parameterized::TableSyntax

    where(:system, :action, :result) do
      false | nil      | 'this, has, some, commas'
      true  | nil      | 'this, has, some, commas'
      true  | 'relate' | 'this, has, some, commas'
      true  | 'weight' | 'this has some commas'
    end

    with_them do
      let(:note) { create(:note, system: system, note: 'this, has, some, commas') }

      before do
        create(:system_note_metadata, action: action, note: note) if action
      end

      it 'returns the right raw note' do
        expect(note.note).to eq(result)
      end

      it 'returns the right HTML' do
        expect(note.note_html).to eq("<p dir=\"auto\">#{result}</p>")
      end
    end
  end
end
