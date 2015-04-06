require 'spec_helper'

RSpec.describe CreatesApplicationFromDraft do
  let(:application_draft) { build_stubbed :application_draft }

  subject { described_class.new application_draft }

  describe 'its constructor' do
    it 'sets the application draft' do
      subject = described_class.new application_draft
      expect(subject.application_draft).to eql application_draft
    end
  end

  describe '#save' do
    let(:application_draft) { create :application_draft, :appliable }
    let(:team)              { create :team, :applying_team }

    context 'with a draft that is not ready yet' do
      let(:application_draft) { ApplicationDraft.new }

      it 'will not create an application' do
        expect { subject.save }.not_to change { ApplicationDraft.count }
      end

      it 'returns nil' do
        expect(subject.save).to be_falsey
      end
    end

    context 'with application created' do
      before do
        described_class.new(application_draft).save
      end

      subject { Application.last }

      it 'pings the mentors' do
        skip
      end

      it 'sets the saison' do
        expect(subject.season).to be_present
        expect(subject.season).to eql application_draft.season
      end

      it 'adds a database reference to itself' do
        expect(subject.application_draft).to eql application_draft
      end

      context 'carrying over the user attributes' do
        shared_examples_for 'matches corresponding user attribute' do |attribute|
          it "will not leave application.#{attribute} blank" do
            expect(subject.application_data[attribute]).to be_present
          end

          it "sets application.#{attribute} to its corresponding draft attribute" do
            draft_attribute = application_draft.send(attribute)
            expect(subject.application_data[attribute]).to eql draft_attribute.to_s
          end
        end

        described_class::STUDENT_FIELDS.each do |student_attribute|
          it_behaves_like 'matches corresponding user attribute', student_attribute
        end

      end
    end
  end
end
