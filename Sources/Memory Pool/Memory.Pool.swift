public import Cardinal
import Index
public import Memory
public import Tagged

extension Memory {
    public enum Pool {
    }
}

extension Memory.Pool {

    public typealias Count = Tagged::Tagged<Slot, Cardinal::Cardinal>

}
