import UIKit

typealias ItemSnapshot = NSDiffableDataSourceSnapshot<Int, Item>

struct Item: Hashable {
    let title: String
    var selected: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
    }
}

final class ViewController: UIViewController, UITableViewDelegate {
    lazy var source: [Item] = (0...30).map { .init(title: String($0), selected: false) }
    
    lazy var diffableDataSource: UITableViewDiffableDataSource<Int, Item> = {
        UITableViewDiffableDataSource<Int, Item>(
            tableView: tableView,
            cellProvider: { [weak self] (tv, indexPath, item) -> UITableViewCell? in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                if let item = self?.source[indexPath.row] {
                    cell.textLabel?.text = item.title
                    cell.accessoryType = item.selected ? .checkmark : .none
                }
            return cell
        })
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = .init(title: "Shuffle", style: .plain, target: self, action: #selector(handleShuffle))
        
        diffableDataSource.apply(source.snapshot, animatingDifferences: true)
    }
    
    @objc func handleShuffle() {
        source.shuffle()
        diffableDataSource.apply(source.snapshot, animatingDifferences: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        
        source[row].selected.toggle()
        let item = source[row]
        
        if item.selected {
            source.remove(at: row)
            source.insert(item, at: 0)
        }
        
        var snapshot = source.snapshot
        diffableDataSource.apply(snapshot, animatingDifferences: true)
        snapshot.reconfigureItems([item])
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension Array where Element == Item {
    var snapshot: ItemSnapshot {
        var snapshot = ItemSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(self)
        return snapshot
    }
}
