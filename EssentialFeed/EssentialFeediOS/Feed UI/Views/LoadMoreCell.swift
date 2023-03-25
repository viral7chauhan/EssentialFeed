//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Falguni Viral Chauhan on 29/01/23.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
	private lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .medium)
		contentView.addSubview(spinner)
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
		])
		return spinner
	}()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        return label
    }()
	
	public var isLoading: Bool {
		get { spinner.isAnimating }
		set {
			newValue
			? spinner.startAnimating()
			: spinner.stopAnimating()
		}
	}
    
    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
}
