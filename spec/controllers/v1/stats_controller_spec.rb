require 'rails_helper'
require 'support/shared_example_symptoms_counts_factory'
require_relative '__version__'

RSpec.describe  V1::StatsController, type: :controller do
  describe '#count' do
    it { should route(:get, @version + '/stats/count').to(action: :count) }
    it_behaves_like 'GET protected with authentication controller', :count

    context 'with valid authentication headers' do
      number_of_symptoms = 2

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      before(:each) do
        @user, @symptoms, @january_2005_10_o_clock, @one_day_later, @two_days_later = create_symptom_and_occurrences_for_spec_per_hours(number_of_symptoms, @user)
      end

      context 'without parameters' do
        before(:each) do
          get :count
        end

        it 'responds with status 400' do
          is_expected.to respond_with 400
        end
      end

      context 'with a valid start and end parameters' do
        start_date = '2005-01-01 10:00:00'
        end_date = '2005-01-01 12:00:00'

        context 'without optional parameters' do
          before(:each) do
            get :count, start: start_date, end: end_date
          end

          it 'responds with status 200' do
            is_expected.to respond_with 200
          end

          describe 'the answer' do
            before(:each) do
              @parsed_response = JSON.parse(response.body)
            end

            it 'is a JSON' do
              expect(response.body).to be_instance_of(String)
              JSON.parse(response.body)
            end

            it 'contains a key named symptoms that is an array' do
              expect(@parsed_response).to have_key('symptoms')
              expect(@parsed_response['symptoms']).to be_an Array
            end

            it 'contains a key named unit that is equal to "days"' do
              expect(@parsed_response).to have_key('unit')
              expect(@parsed_response['unit']).to eq 'days'
            end

            describe 'each element of the array "symptoms"' do
              before(:each) do
                @symptoms = @parsed_response['symptoms']
              end

              it 'contains an id' do
                @symptoms.each do |symptom|
                  expect(symptom).to have_key('id')
                end
              end

              it 'contains a name' do
                @symptoms.each do |symptom|
                  expect(symptom).to have_key('name')
                end
              end

              it 'contains an array named "counts" of size 1' do
                @symptoms.each do |symptom|
                  expect(symptom).to have_key('counts')
                  expect(symptom['counts']).to be_an Array
                  expect(symptom['counts'].length).to eq 1
                end
              end

              describe 'each element of the array "counts"' do
                it 'has a date' do
                  @symptoms.each do |symptom|
                    symptom['counts'].each do |average|
                      expect(average).to have_key('date')
                    end
                  end
                end

                it 'has a count' do
                  @symptoms.each do |symptom|
                    symptom['counts'].each do |average|
                      expect(average).to have_key('count')
                    end
                  end
                end
              end
            end
          end
        end

        context 'with unit = hours' do
          unit = 'hours'
          before(:each) do
            get :count, start: start_date, end: end_date, unit: unit
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has unit = hours' do
            expect(JSON.parse(response.body)['unit']).to eq unit
          end
        end

        context 'with unit = days' do
          unit = 'days'
          before(:each) do
            get :count, start: start_date, end: end_date, unit: unit
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has unit = days' do
            expect(JSON.parse(response.body)['unit']).to eq unit
          end
        end

        context 'with unit = months' do
          unit = 'months'
          before(:each) do
            get :count, start: start_date, end: end_date, unit: unit
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has unit = months' do
            expect(JSON.parse(response.body)['unit']).to eq unit
          end
        end

        context 'with unit = years' do
          unit = 'years'
          before(:each) do
            get :count, start: start_date, end: end_date, unit: unit
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has unit = years' do
            expect(JSON.parse(response.body)['unit']).to eq unit
          end
        end

        context 'with invalid unit' do
          unit = 'invalid'
          before(:each) do
            get :count, start: start_date, end: end_date, unit: unit
          end

          it 'responds with an error 400' do
            is_expected.to respond_with 400
          end
        end

        context 'with symptoms that filter only one symptom' do
          before(:each) do
            symptoms = [@symptoms[0].id]
            get :count, start: start_date, end: end_date, symptoms: symptoms
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has one symptoms' do
            expect(JSON.parse(response.body)['symptoms'].length).to eq 1
          end
        end

        context 'with invalid symptoms' do
          symptoms = [-1]
          before(:each) do
            get :count, start: start_date, end: end_date, symptoms: symptoms
          end

          it 'responds with a status 200' do
            is_expected.to respond_with 200
          end

          it 'has no symptoms' do
            expect(JSON.parse(response.body)['symptoms'].length).to eq 0
          end
        end
      end

      context 'with an invalid start, and end date' do
        start_date = 'this is not a valid date'
        end_date = 'neither is this'
        before(:each) do
          get :count, start: start_date, end: end_date
        end

        it 'responds with an error 400' do
          is_expected.to respond_with 400
        end
      end

    end
  end
end