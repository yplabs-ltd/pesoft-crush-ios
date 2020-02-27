import Foundation
import Alamofire
import SwiftyJSON


enum ApiParameterEncoding {
    case url
    case json
}

class ClientRequest: URLRequestConvertible {
    var buildInfo: ApiRequest.Builder!
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = URL(string: buildInfo.url)!
        //let url = baseURL.appendingPathComponent(path)
        var mutableURLRequest = URLRequest(url: baseURL)
        mutableURLRequest.httpMethod = buildInfo.method.rawValue
        
        switch buildInfo.paramEncoding {
        case .json:
            return try Alamofire.JSONEncoding.default.encode(mutableURLRequest, with: buildInfo.parameters)
        default:
            return try Alamofire.URLEncoding.default.encode(mutableURLRequest, with: buildInfo.parameters)
        }
    }
    
    init(build: ApiRequest.Builder) {
        buildInfo = build
    }
}

class ApiRequest {
    private static let http: SessionManager = {
        let cfg = URLSessionConfiguration.default
        cfg.httpCookieStorage = HTTPCookieStorage.shared
        cfg.timeoutIntervalForResource = 5 // second
        cfg.timeoutIntervalForRequest = 5
        return SessionManager(configuration: cfg)
        }()
    
    typealias ResponseJsonFuncType = (URLRequestConvertible?, HTTPURLResponse?, JSON) -> ApiResponseModel?
    typealias ResponseHandlersFuncType = (_ completionHandler: (ApiResponse) -> ()) -> ()
    
    private let url: String
    private let method: Alamofire.HTTPMethod
    private let parameters: [String: AnyObject]?
    private let paramEncoding: ApiParameterEncoding
    private let jsonToModelHandler: ResponseJsonFuncType?
    private let completionHandler: ((ApiResponse) -> ())?
    private let parts: [(name: String, value: Data)]?
    private var cliendRequest: ClientRequest!
    private var retryCnt = 0
    //private(set) var req: Request?
    
    init (_ builder: ApiRequest.Builder) {
        url = builder.url
        method = builder.method
        parameters = builder.parameters
        paramEncoding = builder.paramEncoding
        jsonToModelHandler = builder.jsonToModelHandler
        completionHandler = builder.completionHandler
        parts = builder.parts
        
        cliendRequest = ClientRequest(build: builder)
    }
    
    // MARK: - request func    
    func setPreviousCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        guard let cookies = cookieStorage.cookies else {
            return
        }

        for cookie in cookies {
            if cookie.name == "CrushAccessToken" {
                HTTPCookieStorage.shared.setCookie(cookie)
                print("ORGcookie: \(cookie)")
            }
        }
    }
    
    func request() {
        //setPreviousCookies()
        if let parts = parts {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (name, data) in parts {
                    multipartFormData.append(data, withName: name)
                }
                print("")
            }, to: "https://hellovoicebucket.s3.amazonaws.com")
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        //self.delegate?.showSuccessAlert()
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        //                        self.showSuccesAlert()
                        //self.removeImage("frame", fileExtension: "txt")
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                        
                        let _ = self.requestAPI(response.request as! URLRequestConvertible)
                    }
                case .failure(let encodingError):
                    //self.delegate?.showFailAlert()
                    print(encodingError)
                }
            }
            
            // mutiparts request
            /*
            upload(multipartFormData: { (multipartFormData) -> Void in
                // parts dictionary 의 순서 유지를 위해 for - in 사용 해야 함
                for (name, data) in parts {
                    multipartFormData.append(data, withName: name)
                }
            }, to: cliendRequest as! URLConvertible, encodingCompletion: { (encodingResult) -> Void in
                switch encodingResult {
                case .success(let request, _, _):
                    let _ = self.requestAPI(request as! URLRequestConvertible)
                case .failure(let errorType):
                    _app.log.error("\(errorType)")
                }
            })*/
        } else {
            let _ = requestAPI(cliendRequest)
        }
    }
    
    func requestAPI(_ URLRequest: URLRequestConvertible) -> Request {
        
        let request = ApiRequest.http.request(URLRequest).response(completionHandler: {
            response in
            let error = response.error
            let url = URLRequest.urlRequest?.url?.absoluteString ?? ""
            _app.log.debug("retryCnt: \(self.retryCnt), statusCode: \(response.response?.statusCode ?? -999), url: \(url)")
            
            if let e = error {
                _app.log.debug("error : \(e)")
            }
            
            guard let statusCode = response.response?.statusCode , error == nil else {
                // statusCode 를 (timeout) 못받은 경우, retry
                self.retry()
                return
            }
            guard let data = response.data else {
                _app.log.error("response data error")
                return
            }
            
            var apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setServerResponseHeader(serverResponseHeader: response.response?.allHeaderFields))
            
            // s3 는 upload 성공 시 204가 내려옴
            if statusCode == 200 || statusCode == 204 {
                if let jsonToModelHandler = self.jsonToModelHandler {
                    do {
                        let json = try JSON(data: data)
                        let model = jsonToModelHandler(response.request, response.response, json)
                        apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setModel(model: model).setServerResponseHeader(serverResponseHeader: response.response?.allHeaderFields))
                    }catch {
                        _app.log.error("Error: Modeling")
                    }
                } else {
                    if let requestBody = response.request?.httpBody {
                        if let requestString =  NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            _app.log.error("requestBody: \(requestString)")
                        }
                    }
                    
                    apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setModel(model: data).setServerResponseHeader(serverResponseHeader: response.response?.allHeaderFields))
                }
            } else {
                
                if let requestBody = response.request?.httpBody {
                    if let requestString =  NSString(data: requestBody, encoding: String.Encoding.utf8.rawValue) {
                        _app.log.error("requestBody: \(String(describing: requestString))")
                    }
                }
                _app.log.error("statusCode: \(statusCode) : \(NSString(data: data, encoding: String.Encoding.utf8.rawValue))")
                do {
                    let json = try JSON(data: data)
                    let errorModel = ServerDefaultResponseModel(json: json)
                    
                    
                    alert(title: errorModel.title ?? "", message: errorModel.description ?? "")
                    apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setServerErrorModel(serverErrorModel: errorModel).setServerResponseHeader(serverResponseHeader: response.response?.allHeaderFields))
                }catch {
                    
                }
            }
            self.completionHandler?(apiResponse)
            
        })
        
        return request
    }
    
    /*
    fileprivate func response(request: Request) {
        
        request.response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: ErrorType?) -> Void in
            
            _app.log.debug("retryCnt: \(self.retryCnt), statusCode: \(response?.statusCode ?? -999), error: \(error), url: \(request?.URL?.absoluteString ?? "")")
            guard let statusCode = response?.statusCode , error == nil else {
                // statusCode 를 (timeout) 못받은 경우, retry
                self.retry()
                return
            }
            guard let data = data else {
                _app.log.error("response data error")
                return
            }
            
            var apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setServerResponseHeader(response?.allHeaderFields))
            
            // s3 는 upload 성공 시 204가 내려옴
            if statusCode == 200 || statusCode == 204 {
                if let jsonToModelHandler = self.jsonToModelHandler {
                    let json = JSON(data: data)
                    let model = jsonToModelHandler(request, response, json)
                    apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setModel(model).setServerResponseHeader(response?.allHeaderFields))
                } else {
                    if let requestBody = request?.HTTPBody {
                        let requestString =  NSString(data: data, encoding: NSUTF8StringEncoding)
                        print(requestString)
                        //_app.log.error("requestBody: \(requestString)")
                    }
                    
                    apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setModel(data).setServerResponseHeader(response?.allHeaderFields))
                }
            } else {
                if let requestBody = request?.HTTPBody {
                    let requestString =  NSString(data: requestBody, encoding: NSUTF8StringEncoding)
                    _app.log.error("requestBody: \(requestString)")
                }
                _app.log.error("statusCode: \(statusCode) : \(NSString(data: data, encoding: NSUTF8StringEncoding))")
                let json = JSON(data: data)
                let errorModel = ServerDefaultResponseModel(json: json)
                

                alert(errorModel.title ?? "", message: errorModel.description ?? "")
                apiResponse = ApiResponse(ApiResponse.Builder(statusCode: statusCode).setServerErrorModel(errorModel).setServerResponseHeader(response?.allHeaderFields))
            }
            self.completionHandler?(apiResponse)
            
        })
    }*/
    
    private func retry() {
        if retryCnt < 3 {
            retryCnt += 1
            request()
        } else {
            //  503 Service Unavailable
            let errorModel = ServerDefaultResponseModel(code: "503", title: "Service Unavailable", description: "Service Unavailable")
            let apiResponse = ApiResponse(ApiResponse.Builder(statusCode: 503).setServerErrorModel(serverErrorModel: errorModel))
            completionHandler?(apiResponse)
        }
    }
    
    struct Builder {
        fileprivate var url: String = ""
        fileprivate var method = Alamofire.HTTPMethod.get
        fileprivate var parameters: [String: AnyObject]?
        fileprivate var paramEncoding = ApiParameterEncoding.url
        fileprivate var jsonToModelHandler: ResponseJsonFuncType?
        fileprivate var completionHandler: ((ApiResponse) -> ())?
        fileprivate var parts: [(name: String, value: Data)]?
        
        func url(url: String) -> Builder {
            var builder = self
            builder.url = url
            return builder
        }
        
        func method(method: Alamofire.HTTPMethod) -> Builder {
            var builder = self
            builder.method = method
            return builder
        }
        
        func parameters(parameters: [String: AnyObject]) -> Builder {
            var builder = self
            builder.parameters = parameters
            return builder
        }
        
        func paramEncoding(paramEncoding: ApiParameterEncoding) -> Builder {
            var builder = self
            builder.paramEncoding = paramEncoding
            return builder
        }
        
        func jsonToModelHandler(jsonToModelHandler: @escaping ResponseJsonFuncType) -> Builder {
            var builder = self
            builder.jsonToModelHandler = jsonToModelHandler
            return builder
        }
        
        func completionHandler(completionHandler: @escaping (ApiResponse) -> ()) -> Builder {
            var builder = self
            builder.completionHandler = completionHandler
            return builder
        }
    
        func parts(parts: [(name: String, value: Data)]?) -> Builder {
            var builder = self
            builder.parts = parts
            return builder
        }
        
    }
}


