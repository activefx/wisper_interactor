require 'spec_helper'

RSpec.describe WisperInteractor::Base do

  let(:klass) { described_class.clone }
  let(:instance) { klass.new(Hash.new) }

  it "includes the the Interactor module" do
    expect(described_class.ancestors).to include Interactor
  end

  it "includes the Wisper::Publisher module" do
    expect(described_class.ancestors).to include Wisper::Publisher
  end

  context ".on_success" do

    it "accepts a block and sets the on_success_callback" do
      blk = Proc.new {}
      klass.on_success(&blk)
      expect(klass.on_success_callback).to eq blk
    end

    it "when called without a block resets the on_success_callback" do
      blk = Proc.new {}
      klass.on_success(&blk)
      klass.on_success
      expect(klass.on_success_callback).to be_nil
    end

    it "requires a block" do
      expect{ klass.on_success(nil) }.to raise_error ArgumentError
    end

  end

  context ".on_failure" do

    it "accepts a block and sets the on_failure_callback" do
      blk = Proc.new {}
      klass.on_failure(&blk)
      expect(klass.on_failure_callback).to eq blk
    end

    it "when called without a block resets the on_failure_callback" do
      blk = Proc.new {}
      klass.on_failure(&blk)
      klass.on_failure
      expect(klass.on_failure_callback).to be_nil
    end

    it "requires a block" do
      expect{ klass.on_failure(nil) }.to raise_error ArgumentError
    end

  end

  context ".perform" do

    it "accepts a block and sets the instructions" do
      blk = Proc.new {}
      klass.perform(&blk)
      expect(klass.instructions).to eq blk
    end

    it "when called without a block resets the instructions" do
      blk = Proc.new {}
      klass.perform(&blk)
      klass.perform
      expect(klass.instructions).to be_nil
    end

    it "requires a block" do
      expect{ klass.perform(nil) }.to raise_error ArgumentError
    end

  end

  context ".on_success_callback=" do

    it "sets the on_success_callback" do
      klass.on_success_callback = 'value'
      expect(klass.on_success_callback).to eq 'value'
    end

  end

  context ".on_success_callback" do

    it "is nil by default" do
      expect(klass.on_success_callback).to be_nil
    end

  end

  context ".on_failure_callback=" do

    it "sets the on_failure_callback" do
      klass.on_failure_callback = 'value'
      expect(klass.on_failure_callback).to eq 'value'
    end

  end

  context ".on_failure_callback" do

    it "is nil by default" do
      expect(klass.on_failure_callback).to be_nil
    end

  end

  context ".instructions=" do

    it "sets the instructions" do
      klass.instructions = 'value'
      expect(klass.instructions).to eq 'value'
    end

  end

  context ".instructions" do

    it "is nil by default" do
      expect(klass.instructions).to be_nil
    end

  end

  context ".subscribers" do

    it "is empty by default" do
      expect(klass.subscribers).to be_empty
    end

  end

  context ".subscribe" do

    it "adds a subscribe" do
      expect{
        klass.subscribe('subscriber')
      }.to change{
        klass.subscribers.count
      }.by(1)
    end

  end

  context ".call" do

    let(:context) { double(:context) }
    let(:instance_dbl) { double(:instance_dbl, context: context) }

    it "initializes the interactor" do
      context_args = { foo: 'bar' }
      expect(klass).to receive(:new).with(context_args)
        .and_return(klass.new(context_args))
      klass.call(context_args)
    end

    it "calls run on the instance" do
      expect(klass).to receive(:new).once.with(foo: 'bar') { instance_dbl }
      expect(instance_dbl).to receive(:run).once.with(no_args)
      expect(klass.call(foo: 'bar')).to eq(context)
    end

    it "rescues failures" do
      klass.perform { context.fail! }
      expect { klass.call }.not_to raise_error
    end

  end

  context ".call!" do

    let(:context) { double(:context) }
    let(:instance_dbl) { double(:instance_dbl, context: context) }

    it "initializes the interactor" do
      context_args = { foo: 'bar' }
      expect(klass).to receive(:new).with(context_args)
        .and_return(klass.new(context_args))
      klass.call!(context_args)
    end

    it "calls run! on the instance" do
      expect(klass).to receive(:new).once.with(foo: 'bar') { instance_dbl }
      expect(instance_dbl).to receive(:run!).once.with(no_args)
      expect(klass.call!(foo: 'bar')).to eq(context)
    end

    it "does not rescue failures" do
      klass.perform { context.fail! }
      expect { klass.call! }.to raise_error Interactor::Failure
    end

  end

  context "#run!" do

    it "subscribes configured listeners" do
      listener = double('Listener')
      klass.subscribe listener
      klass.on_success do
        broadcast(:interactor_succeeded)
      end
      expect(listener).to receive(:interactor_succeeded)
      instance.run!
    end

    it "executes the instructions" do
      klass.perform do
        raise StandardError
      end
      expect{ instance.run! }.to raise_error StandardError
    end

    it "executes the on_success_callback on success" do
      klass.on_success do
        broadcast(:interactor_succeeded)
      end
      expect { instance.run! }.to broadcast(:interactor_succeeded)
    end

    it "does not execute on_failure_callback on success" do
      klass.on_failure do
        broadcast(:interactor_failed)
      end
      expect { instance.run! }.not_to broadcast(:interactor_failed)
    end

    it "executes the on_failure_callback on failure" do
      klass.on_failure do
        broadcast(:interactor_failed)
      end
      klass.perform do
        raise StandardError
      end
      expect {
        begin; instance.run!; rescue StandardError; end
      }.to broadcast(:interactor_failed)
    end

    it "does not executes the on_failure_callback on failure" do
      klass.on_success do
        broadcast(:interactor_succeeded)
      end
      klass.perform do
        raise StandardError
      end
      expect {
        begin; instance.run!; rescue StandardError; end
      }.not_to broadcast(:interactor_succeeded)
    end

    it "tracks that the interactor was called" do
      instance.run!
      expect(instance.context._called).to include instance
    end

    it "attempts to rollback other interactors on failure" do
      klass.perform do
        context.fail!
      end
      expect(instance.context).to receive(:rollback!)
      begin; instance.run!; rescue Interactor::Failure; end
    end

    it "raises Interactor::Failure on failure" do
      klass.perform do
        context.fail!
      end
      expect{ instance.run! }.to raise_error Interactor::Failure
    end

  end

  context "#call" do

    it "executes the instructions" do
      blk = Proc.new { }
      klass.perform(&blk)
      expect(instance).to receive(:instance_exec) do |*args, &block|
        expect(blk).to be(block)
      end
      instance.call
    end

    it "does not execute on_success_callback" do
      klass.on_success do
        broadcast(:interactor_succeeded)
      end
      expect { instance.call }.not_to broadcast(:interactor_succeeded)
    end

    it "does not execute on_failure_callback" do
      klass.on_failure do
        broadcast(:interactor_failed)
      end
      klass.perform do
        context.fail!
      end
      expect {
        begin; instance.call; rescue Interactor::Failure; end
      }.not_to broadcast(:interactor_failed)
    end

  end

end
