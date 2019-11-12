import UIKit
import SparkleCommon

public class MiniToastView: UIView {
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        // label.font = .body
        // label.textColor = .text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.fillInSuperview(insets: UIEdgeInsets(top: .mediumSpacing, leading: .mediumLargeSpacing, bottom: -.mediumSpacing, trailing: -.mediumLargeSpacing))
        // backgroundColor = .bgAlert
        layer.cornerRadius = .mediumLargeSpacing
    }

    required init?(coder aDecoder: NSCoder) { fatalError("") }

    public func show(in view: UIView) {
        view.addSubview(self)
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.largeSpacing),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        animate()
    }

    @objc func animate() {
        UIView.animate(withDuration: 0.3, delay: 1, options: [.curveEaseInOut], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            self.hide()
        })
    }

    @objc func hide() {
        UIView.animate(withDuration: 0.3, delay: 4, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
