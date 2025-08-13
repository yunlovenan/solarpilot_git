pipeline {
    agent {
        label 'appium-node'  // 指定使用appium-node节点
    }
    
    environment {
        // 设置环境变量
        PYTHON_VERSION = '3.13'
        PROJECT_DIR = '/jenkins/workspace/app_testing'
        VENV_PATH = '/jenkins/venv'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '🔍 检出代码...'
                // 如果使用Git，可以添加checkout步骤
                // checkout scm
            }
        }
        
        stage('Setup Environment') {
            steps {
                echo '🔧 设置环境...'
                sh '''
                    echo "当前工作目录: $(pwd)"
                    echo "当前用户: $(whoami)"
                    echo "Python版本: $(python3 --version)"
                    echo "节点名称: $NODE_NAME"
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '📦 安装依赖包...'
                sh '''
                    # 创建虚拟环境（如果不存在）
                    if [ ! -d "$VENV_PATH" ]; then
                        python3 -m venv $VENV_PATH
                    fi
                    
                    # 激活虚拟环境并安装依赖
                    source $VENV_PATH/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 运行测试...'
                sh '''
                    # 激活虚拟环境
                    source $VENV_PATH/bin/activate
                    
                    # 运行移动端测试
                    echo "开始运行移动端测试..."
                    python3 run.py mobile
                    
                    # 检查测试结果
                    if [ $? -eq 0 ]; then
                        echo "✅ 测试执行成功"
                    else
                        echo "❌ 测试执行失败"
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Generate Reports') {
            steps {
                echo '📊 生成测试报告...'
                sh '''
                    # 激活虚拟环境
                    source $VENV_PATH/bin/activate
                    
                    # 生成Allure报告
                    if [ -d "allure_results" ]; then
                        allure generate allure_results/ --clean -o allure_report/
                        echo "✅ 测试报告生成成功"
                    else
                        echo "⚠️ 没有找到测试结果文件"
                    fi
                '''
            }
        }
        
        stage('Archive Results') {
            steps {
                echo '📁 归档测试结果...'
                archiveArtifacts artifacts: 'allure_report/**/*', fingerprint: true
                archiveArtifacts artifacts: 'result/**/*', fingerprint: true
            }
        }
    }
    
    post {
        always {
            echo '🧹 清理工作空间...'
            cleanWs()
        }
        success {
            echo '🎉 构建成功！'
        }
        failure {
            echo '❌ 构建失败！'
        }
    }
}
