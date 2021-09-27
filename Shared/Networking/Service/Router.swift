//
//  Router.swift
//  Portal
//
//  Created by Farid on 12/09/2018.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation
import Combine

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func dispatch(_ route: EndPoint) -> AnyPublisher<(data: Data, response: URLResponse), URLError>?
    func cancel()
}

class Router<EndPoint: EndPointType>: NetworkRouter, BinanceRequestConfig, CoinbaseProRequestConfig, KrakenRequestConfig {
    private var task: URLSessionTask?
    private let session = URLSession(configuration: .default)
    private let networkQueue = DispatchQueue(label: "com.portal.network.layer.queue")
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        networkQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let request = try self.buildRequest(from: route)
                NetworkLogger.log(request: request)
                self.task = self.session.dataTask(with: request, completionHandler: { data, response, error in
                    completion(data, response, error)
                })
            } catch {
                completion(nil, nil, error)
            }
            self.task?.resume()
        }
    }
    
    func dispatch(_ route: EndPoint) -> AnyPublisher<(data: Data, response: URLResponse), URLError>? {
        do {
            let request = try self.buildRequest(from: route)
            return self.session.dataTaskPublisher(for: request).eraseToAnyPublisher()
        } catch {
            return nil
        }
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .binanceSignedRequest(let urlParameters,
                                       let credentials):
                
                self.configureBinanceRequest(urlParameters,
                                             credentials: credentials,
                                             request: &request)
                
            case .krakenSignedRequest(let urlParameters,
                                      let credentials,
                                      let path):
                
                self.configureKrakenRequest(urlParameters,
                                             credentials: credentials,
                                             request: &request,
                                             path: path)
                
            case .coinbaseProSignedRequest(let urlParameters,
                                           let credentials,
                                           let path):
                
                self.configureCoinbaseProRequest(urlParameters,
                                                 credentials: credentials,
                                                 path: path,
                                                 request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

enum NetworkRequestError: LocalizedError, Equatable, Error {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case httpError2xx(_ code: Int)
}
