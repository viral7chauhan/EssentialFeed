//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Falguni Viral Chauhan on 29/01/23.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
	lazy var spinner: UIActivityIndicatorView = {
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
	
	public var isLoading: Bool {
		get { spinner.isAnimating }
		set {
			newValue
			? spinner.startAnimating()
			: spinner.stopAnimating()
		}
	}
}
