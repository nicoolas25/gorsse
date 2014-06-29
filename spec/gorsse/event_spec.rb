require 'test_helper.rb'

describe Gorsse::Event do
  let(:protocol_class) { stub_const('Protocol', Class.new(Gorsse::Protocol)) }
  let(:event) { Gorsse::Event.new(protocol, target, entity) }

  describe '#send!' do
    before { allow(Gorsse.conn).to receive(:send).and_return(nil) }

    subject { event.send! }

    let(:scope) { 'scope' }
    let(:protocol) { protocol_class.new(scope) }
    let(:target) { :all }
    let(:entity) { 'no_data' }

    it 'sends json event data though the Gorsse.conn connection' do
      expected_json = %Q({"proto":"Protocol","scope":"scope","client":"all","title":"no_data","content":""})
      expect(Gorsse.conn).to receive(:send).with(expected_json)
      subject
    end

    context 'when the target is a client' do
      let(:target) { Gorsse::Client.new('1234') }

      it 'sends the client uid in the "client" fields' do
        expected_json = %Q({"proto":"Protocol","scope":"scope","client":"1234","title":"no_data","content":""})
        expect(Gorsse.conn).to receive(:send).with(expected_json)
        subject
      end
    end

    context 'when the entity respond to the "to_sse" method' do
      let(:entity) { double( class: double( name: 'Entity' ) ) }

      it 'sends the entity class name as the "title" field' do
        expected_json = %Q({"proto":"Protocol","scope":"scope","client":"all","title":"Entity","content":""})
        allow(entity).to receive(:to_sse).and_return('')
        expect(Gorsse.conn).to receive(:send).with(expected_json)
        subject
      end

      it 'sends the result of the "to_sse" call as the "content" field' do
        expected_json = %Q({"proto":"Protocol","scope":"scope","client":"all","title":"Entity","content":"data"})
        allow(entity).to receive(:to_sse).and_return('data')
        expect(Gorsse.conn).to receive(:send).with(expected_json)
        subject
      end
    end
  end
end
