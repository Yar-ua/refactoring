require_relative '../src/loader'

RSpec.describe Console do
  let(:current_subject) { described_class.new }
  let(:valid_string) { 'qweqwe' }
  let(:valid_age) { '26' }
  let(:valid_name) { 'John' }
  let(:real_account) { Account.new(name: valid_name, age: valid_age, login: valid_string, password: valid_string) }
  let(:card_console) { CardsConsole.new(real_account) }
  let(:overridable_filename) { 'spec/fixtures/account.yml' }

  describe '#main_menu' do
    before { allow(current_subject).to receive(:main_menu) }

    context 'when correct method calling' do
      it 'create account if input is create' do
        allow(current_subject).to receive(:user_input).and_return('create')
        expect(current_subject).to receive(:create_account)
        current_subject.console_menu
      end

      it 'load account if input is load' do
        allow(current_subject).to receive(:user_input).and_return('load')
        expect(current_subject).to receive(:load_account)
        current_subject.console_menu
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive(:user_input).and_return('another')
        expect(current_subject).to receive(:exit)
        current_subject.console_menu
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_create_command_input) { 'create' }
    let(:success_inputs) do
      [success_name_input,
       success_age_input, success_login_input, success_password_input]
    end

    context 'with success result' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(success_create_command_input,
                                                                                  *success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:db_accounts).and_return([])
        stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)
      end

      after do
        File.delete(overridable_filename) if File.exist?(overridable_filename)
      end

      it 'with correct outout' do
        allow(File).to receive(:open)
        I18n.t(:ask).each_value { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        I18n.t(:validation).values.map do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.console_menu
      end

      it 'write to file Account instance' do
        current_subject.console_menu
        expect(File.exist?(overridable_filename)).to be true
        accounts = YAML.load_file(overridable_filename)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = [success_create_command_input] + current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:db_accounts).and_return([])
        stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { I18n.t(:validation)[:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) do
          [success_name_input, success_age_input,
           error_input, success_password_input]
        end

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { I18n.t(:validation)[:login][:present] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { I18n.t(:validation)[:login][:longer] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { I18n.t(:validation)[:login][:shorter] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { I18n.t(:validation)[:age] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { I18n.t(:validation)[:password][:present] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { I18n.t(:validation)[:password][:longer] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { I18n.t(:validation)[:password][:shorter] }

          it { expect { current_subject.console_menu }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    let(:success_load_command_input) { 'load' }

    context 'without active accounts' do
      it do
        allow(current_subject).to receive(:user_input).and_return(success_load_command_input)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:db_accounts).and_return([])
        allow(current_subject).to receive(:create_the_first_account).and_return([])
        current_subject.console_menu
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }
      let(:account_double) { instance_double('Account', login: login, password: password) }

      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(success_load_command_input,
                                                                                  *all_inputs)
        allow(current_subject).to receive(:db_accounts) { [account_double] }
      end

      context 'with correct outout' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          [I18n.t(:hello), I18n.t(:ask)[:login], I18n.t(:ask)[:password]].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.console_menu
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.console_menu }.not_to output(/#{I18n.t(:errors)[:user_not_exists]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.console_menu }.to output(/#{I18n.t(:errors)[:user_not_exists]}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct outout' do
      allow(current_subject).to receive_message_chain(:gets, :chomp)
      expect(current_subject).to receive(:console_menu)
      expect do
        current_subject.send(:create_the_first_account)
      end.to output(I18n.t(:common_phrases)[:no_active_account_yet]).to_stdout
    end

    it 'calls create if user inputs is y' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create_account)
      current_subject.send(:create_the_first_account)
    end

    it 'calls console if user inputs is not y' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:console_menu)
      current_subject.send(:create_the_first_account)
    end
  end

  describe 'main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'PM' => :put_account_money,
        'SM' => :send_account_money,
        'DC' => :destroy_account_card,
        'WM' => :withdraw_account_money,
        'SC' => :show_account_cards,
        'CC' => :create_new_type_card,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive(:show_account_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@account, instance_double('Account', name: name))
        expect { current_subject.send(:main_menu) }.to output(/Welcome, #{name}/).to_stdout
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        expect(current_subject).to receive(:puts).with(I18n.t(:main_menu, name: name)).twice
        current_subject.send(:main_menu)
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@account, instance_double('Account', name: name))
        expect(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.send(:main_menu) }.to output(/#{I18n.t(:errors)[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { real_account }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    after do
      File.delete(overridable_filename) if File.exist?(overridable_filename)
    end

    it 'with correct outout' do
      allow(current_subject).to receive_message_chain(:gets, :chomp)
      expect { current_subject.send(:destroy_account) }.to output(I18n.t(:common_phrases)[:destroy_account]).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        allow(correct_account).to receive(:db_accounts) { accounts }
        current_subject.instance_variable_set(:@account, correct_account)

        current_subject.send(:destroy_account)

        expect(File.exist?(overridable_filename)).to be true
        file_accounts = YAML.load_file(overridable_filename)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        current_subject.send(:destroy_account)

        expect(File.exist?(overridable_filename)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) do
      [instance_double('Usual', number: 1234, type: 'usual'),
       instance_double('Virtual', number: 5678, type: 'virtual')]
    end

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@account, instance_double('Account', cards: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.send(:show_account_cards)
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@account, instance_double('Account', cards: []))
      expect(current_subject).to receive(:puts).with(I18n.t(:errors)[:no_active_cards])
      current_subject.send(:show_account_cards)
    end
  end

  describe '#create_card' do
    context 'with correct outout' do
      it do
        expect(current_subject).to receive(:puts).with(I18n.t('create_card_message'))
        current_subject.instance_variable_set(:@account, real_account)
        allow(current_subject).to receive(:db_accounts).and_return([])
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        current_subject.send(:create_new_type_card)
      end
    end

    context 'when correct card choose' do
      let(:cards) { [CardUsual.new(:usual), CardCapitalist.new(:capitalist), CardVirtual.new(:virtual)] }

      before do
        allow(current_subject).to receive(:db_accounts) { [real_account] }
        stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)
        current_subject.instance_variable_set(:@account, real_account)
      end

      after do
        File.delete(overridable_filename) if File.exist?(overridable_filename)
      end

      it 'create card with card_type' do
        cards.each_with_index do |card, index|
          allow(current_subject).to receive_message_chain(:gets, :chomp) { card.type.to_s }

          current_subject.send(:create_new_type_card)

          expect(File.exist?(overridable_filename)).to be true
          file_accounts = YAML.load_file(overridable_filename)
          expect(file_accounts.first.cards[index].type).to eq card.type.to_s
          expect(file_accounts.first.cards[index].balance).to eq card.balance
          expect(file_accounts.first.cards[index].number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_subject.instance_variable_set(:@account, real_account)
        allow(File).to receive(:open)
        allow(current_subject).to receive(:db_accounts).and_return([])
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect do
          current_subject.send(:create_new_type_card)
        end.to output(/#{I18n.t(:errors)[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        expect do
          current_subject.instance_variable_set(:@account, real_account)
          current_subject.send(:redirect_to_cards_console, 'DC')
        end.to output(/#{I18n.t(:errors)[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double('Usual', number: 1234, type: 'usual') }
      let(:card_two) { instance_double('Virtual', number: 5678, type: 'virtual') }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect do
            card_console.send(:destroy_account_card)
          end.to output(/#{I18n.t(:common_phrases)[:if_you_want_to_delete]}/).to_stdout

          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:destroy_account_card) }.to output(message).to_stdout
          end
          card_console.send(:destroy_account_card)
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:destroy_account_card)
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { card_console.send(:destroy_account_card) }.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { card_console.send(:destroy_account_card) }.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)
          real_account.instance_variable_set(:@cards, fake_cards)
          allow(card_console).to receive(:db_accounts) { [real_account] }
          card_console.instance_variable_set(:@account, real_account)
        end

        after do
          File.delete(overridable_filename) if File.exist?(overridable_filename)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_console.send(:cards_choices, 'DC') }.to change { real_account.cards.size }.by(-1)

          expect(File.exist?(overridable_filename)).to be true
          file_accounts = YAML.load_file(overridable_filename)
          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_console.send(:destroy_account_card) }.not_to change(real_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@account, real_account)
        expect do
          current_subject.send(:redirect_to_cards_console, 'PM')
        end.to output(/#{I18n.t(:errors)[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double('Usual', number: 1234, type: 'usual') }
      let(:card_two) { instance_double('Virtual', number: 5678, type: 'virtual') }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect do
            card_console.send(:cards_choices, 'PM')
          end.to output(/#{I18n.t(:common_phrases)[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:cards_choices, 'PM') }.to output(message).to_stdout
          end
          card_console.send(:cards_choices, 'PM')
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:cards_choices, 'PM')
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { card_console.send(:cards_choices, 'PM') }.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { card_console.send(:cards_choices, 'PM') }.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CardCapitalist.new('capitalist') }
        let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          card_one.instance_variable_set(:@balance, default_balance)
          real_account.instance_variable_set(:@cards, fake_cards)
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            allow(card_console).to receive(:update_db)
            expect do
              card_console.send(:cards_choices, 'PM')
            end.to output(/#{I18n.t(:common_phrases)[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            allow(card_console).to receive(:update_db)
            expect do
              card_console.send(:cards_choices, 'PM')
            end.to output(/#{I18n.t(:errors)[:correct_amount]}/).to_stdout
          end
        end

        context 'with tax greater than amount' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            allow(card_console).to receive(:update_db)
            expect do
              card_console.send(:cards_choices, 'PM')
            end.to output(/#{I18n.t(:errors)[:tax_higher]}/).to_stdout
          end
        end

        context 'with tax lower than amount' do
          let(:custom_cards) do
            [
              CardUsual.new('usual'),
              CardCapitalist.new('capitalist'),
              CardVirtual.new('virtual')
            ]
          end

          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          after do
            File.delete(overridable_filename) if File.exist?(overridable_filename)
          end

          it do
            custom_cards.each do |custom_card|
              custom_card.instance_variable_set(:@balance, default_balance)
              real_account.instance_variable_set(:@cards, [custom_card, card_one, card_two])
              allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
              allow(card_console).to receive(:db_accounts) { [real_account] }
              stub_const('Constants::PATH_TO_DB_FILE', overridable_filename)

              new_balance = default_balance + correct_money_amount_greater_than_tax -
                            custom_card.put_tax(correct_money_amount_greater_than_tax)

              expect do
                card_console.send(:cards_choices, 'PM')
              end.to output(include "Money #{correct_money_amount_greater_than_tax}").to_stdout

              expect(File.exist?(overridable_filename)).to be true
              file_accounts = YAML.load_file(overridable_filename)
              expect(file_accounts.first.cards.first.balance).to eq(new_balance)
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@account, instance_double('Account', cards: []))
        expect do
          current_subject.send(:redirect_to_cards_console, 'WM')
        end.to output(/#{I18n.t(:errors)[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { CardCapitalist.new('capitalist') }
      let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }

          expect do
            card_console.send(:cards_choices, 'WM')
          end.to output(/#{I18n.t(:common_phrases)[:choose_card_withdrawing]}/).to_stdout

          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:cards_choices, 'WM') }.to output(message).to_stdout
          end
          card_console.send(:cards_choices, 'WM')
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:cards_choices, 'WM')
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')

          expect do
            card_console.send(:cards_choices, 'WM')
          end.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')

          expect do
            card_console.send(:cards_choices, 'WM')
          end.to output(/#{I18n.t(:errors)[:wrong_number]}/).to_stdout
        end
      end
    end

    context 'with correct input of card number' do
      let(:card_one) { CardCapitalist.new('capitalist') }
      let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
      let(:fake_cards) { [card_one, card_two] }
      let(:chosen_card_number) { 1 }
      let(:incorrect_money_amount) { -2 }
      let(:default_balance) { 50.0 }
      let(:correct_money_amount_lower_than_tax) { 5 }
      let(:correct_money_amount_greater_than_tax) { 50 }

      before do
        real_account.instance_variable_set(:@cards, fake_cards)
        card_console.instance_variable_set(:@account, real_account)
        allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
      end

      context 'with correct output' do
        let(:commands) { [chosen_card_number, incorrect_money_amount] }

        it do
          allow(card_console).to receive(:update_db)

          expect do
            card_console.send(:cards_choices, 'WM')
          end.to output(/#{I18n.t(:common_phrases)[:withdraw_amount]}/).to_stdout
        end
      end
    end
  end
end
