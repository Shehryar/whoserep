//
//  ImageViewerImagesSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 1/2/19.
//  Copyright © 2019 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ImageViewerImageSpec: QuickSpec {
    override func spec() {
        describe("ImageViewerImageSpec") {
            
            func blankImage(size: CGSize) -> UIImage? {
                UIGraphicsBeginImageContext(size)
                UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image
            }
            
            context("Valid ImageViewerImage") {
                var imageViewerImage: ImageViewerImage?
                beforeEach {
                    let image = blankImage(size: CGSize(width: 10, height: 10))
                    let url = URL(string: "http://fakeurl.com")
                    imageViewerImage = ImageViewerImage(image: image, imageURL: url, caption: "Fake Image")
                }
                
                it("Should have a valid ImageViewImage") {
                    expect(imageViewerImage).toNot(beNil())
                    expect(imageViewerImage?.image).toNot(beNil())
                    expect(imageViewerImage?.imageURL).toNot(beNil())
                    expect(imageViewerImage?.caption).to(equal("Fake Image"))
                }
            }
            
            context("Test class functions") {
                var urls = [URL]()
                var images = [UIImage]()
                
                beforeEach {
                    let urlsArray = [
                        URL(string: "http://fakeurl0.com")!,
                        URL(string: "http://fakeurl1.com")!,
                        URL(string: "http://fakeurl2.com")!
                    ]
                    let imagesArray = [
                        blankImage(size: CGSize(width: 10, height: 10))!,
                        blankImage(size: CGSize(width: 20, height: 20))!,
                        blankImage(size: CGSize(width: 30, height: 30))!
                    ]
                    urls = urlsArray
                    images = imagesArray
                }
                
                it("Should return an array of ImageViewerImages from an array of images") {
                    let array = ImageViewerImage.imagesWithImages(images)
                    expect(array).toNot(beNil())
                    expect(array.count).to(equal(3))
                }
                
                it("Should return an array of ImageViewerImages from an array of urls") {
                    let array = ImageViewerImage.imagesWithImageURLs(urls)
                    expect(array).toNot(beNil())
                    expect(array.count).to(equal(3))
                }
            }
        }
    }
}
