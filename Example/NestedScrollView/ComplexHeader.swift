//
//  ComplexHeader.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/15.
//

import UIKit
import Then
import SwifterSwift
import SnapKit

class ComplexHeader: UIView {
    
    let lb1 = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .red
        $0.text = "Test Complex Header"
    }
    
    let but1 = UIButton(type: .contactAdd)
    
    lazy var hFlow = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 8
        $0.minimumInteritemSpacing = 8
        $0.itemSize = CGSize(width: 150, height: 150)
    }
    
    lazy var hCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hFlow).then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.register(cellWithClass: TestCollectionCell.self)
        $0.dataSource = self
        $0.delegate = self
    }
    
    let blogList = BlogList(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("use init(frame:)")
    }
    
    @objc func popAlert() {
        let av = UIAlertController(title: "Test", message: "test button click", preferredStyle: .alert)
        av.addAction(.init(title: "OK", style: .cancel))
        av.show()
    }
    
    func setupUI() {
        addSubview(lb1)
        lb1.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.height.equalTo(30)
            make.leading.equalTo(16)
        }
        
        addSubview(but1)
        but1.snp.makeConstraints { make in
            make.top.equalTo(lb1.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        but1.addTarget(self, action: #selector(popAlert), for: .touchUpInside)
        
        addSubview(hCollectionView)
        hCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(150)
            make.top.equalTo(but1.snp.bottom).offset(10)
        }
        
        addSubview(blogList)
        blogList.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(hCollectionView.snp.bottom).offset(10)
            make.height.equalTo(316)
        }
    }
}

extension ComplexHeader: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: TestCollectionCell.self, for: indexPath)
        cell.contentView.backgroundColor = .lightGray
        cell.lb.text = "\(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


class TestCollectionCell: UICollectionViewCell {
    let lb = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .blue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class BlogList: UIView {
    let lb = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .cyan
        $0.text = "Blog List"
    }
    
    lazy var vFlow = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 8
        $0.minimumInteritemSpacing = 0
        let width = (screenWidth - 32)
        $0.itemSize = CGSize(width: width, height: 80)
    }
    
    lazy var vCollectionView = UICollectionView(frame: .zero, collectionViewLayout: vFlow).then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.register(cellWithClass: TestCollectionCell.self)
        $0.dataSource = self
        $0.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(lb)
        lb.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.height.equalTo(30)
            make.leading.equalTo(16)
        }
        
        addSubview(vCollectionView)
        vCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(lb.snp.bottom).offset(10)
            make.height.equalTo(256)
        }
    }
}

extension BlogList: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: TestCollectionCell.self, for: indexPath)
        cell.contentView.backgroundColor = .gray
        cell.lb.text = "Blog \(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
